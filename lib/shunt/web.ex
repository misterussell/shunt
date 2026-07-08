defmodule Shunt.Web do
  @moduledoc false

  alias Shunt.Events
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  @status_order %{crackable: 0, lead: 1, forming: 2, solved: 3}

  @doc """
  The player's signal network: every RumorConnection they hold at least one rumor of, decorated
  with what they hold, what they're missing, the total, and the case's status. Cases the player
  holds no rumor of are omitted (hidden). `held`/`missing` preserve the connection's authored rumor
  order. Sorted by status (crackable, then lead, then forming, then solved) and then connection id.

    status ordering (first match wins):
      solved?/2                            -> :solved
      holds every rumor in the set         -> :crackable
      holds >= conn.partial_threshold      -> :lead
      holds >= 1                           -> :forming
  """
  def network(player) do
    held_set = MapSet.new(player.rumors)

    RumorConnection.all()
    |> Enum.flat_map(fn conn ->
      case Enum.filter(conn.rumors, &MapSet.member?(held_set, &1)) do
        [] ->
          []

        held ->
          [
            %{
              connection: conn,
              held: held,
              missing: Enum.reject(conn.rumors, &MapSet.member?(held_set, &1)),
              total: length(conn.rumors),
              status: status(player, conn, length(held))
            }
          ]
      end
    end)
    |> Enum.sort_by(fn %{connection: conn, status: status} ->
      {Map.fetch!(@status_order, status), conn.id}
    end)
  end

  defp status(player, conn, held_count) do
    cond do
      solved?(player, conn) -> :solved
      held_count == length(conn.rumors) -> :crackable
      held_count >= conn.partial_threshold -> :lead
      true -> :forming
    end
  end

  @doc """
  Acts on a case. `:crack` plays its success event; `:lead` plays its partial event. This is
  server-authoritative — the player must actually hold the required intel, since the client can't
  be trusted to have earned it. Probing the network is a commitment: the case's authored heat cost
  (`crack_heat`/`lead_heat`) rides along with the started event.

  Returns `{:ok, [{:heat, cost} | event_effects], %{event_id: event_id}}` so the caller can dispatch
  it in one shot and read the started event id from the meta, or `{:error, reason}` when the player
  doesn't qualify (`:not_found`, `:solved`, `:insufficient_intel`, or `:lead_spent`).
  """
  def pursue(player, connection_id, mode) do
    with {:ok, conn} <- RumorConnection.fetch(connection_id),
         :ok <- validate_pursuit(player, conn, mode) do
      {event_id, heat} = pursuit_target(conn, mode)
      {:ok, event_effects, _meta} = Events.start(player, event_id)
      {:ok, [{:heat, heat} | event_effects], %{event_id: event_id}}
    else
      :error -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  defp pursuit_target(conn, :crack), do: {conn.success_event_id, conn.crack_heat}
  defp pursuit_target(conn, :lead), do: {conn.partial_event_id, conn.lead_heat}

  defp validate_pursuit(player, conn, mode) do
    held_count =
      MapSet.intersection(MapSet.new(player.rumors), MapSet.new(conn.rumors)) |> MapSet.size()

    cond do
      solved?(player, conn) -> {:error, :solved}
      mode == :crack and held_count < length(conn.rumors) -> {:error, :insufficient_intel}
      mode == :lead and held_count < conn.partial_threshold -> {:error, :insufficient_intel}
      mode == :lead and conn.partial_event_id in player.completed_events -> {:error, :lead_spent}
      true -> :ok
    end
  end

  @doc """
  The browse-by-entity axis: the sorted, distinct tags across the rumors the player actually holds.
  Grounds the network in intel collected, not in cases they haven't touched.
  """
  def entities(player) do
    player
    |> held_rumors()
    |> Enum.flat_map(& &1.tags)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Everything the network shows for one entity (tag): the held rumors carrying it (in held order),
  and the `network/1` cases those rumors touch. `%{rumors: [...], cases: [...]}`.
  """
  def entity_view(player, tag) do
    tagged = player |> held_rumors() |> Enum.filter(&(tag in &1.tags))
    tagged_ids = MapSet.new(tagged, & &1.id)

    cases =
      player
      |> network()
      |> Enum.filter(fn %{connection: conn} ->
        Enum.any?(conn.rumors, &MapSet.member?(tagged_ids, &1))
      end)

    %{rumors: tagged, cases: cases}
  end

  # TODO: add entity_graph/1 -> %{nodes: [...], edges: [...]}, the entity-to-entity "signal web"
  #   derived from held rumors only (reuse held_rumors/1). This is a pure function.
  #   Nodes: one per distinct tag, %{tag, weight, cluster, x, y} where weight = number of held
  #     rumors carrying the tag (drives node size). cluster/x/y are filled by the layout below.
  #   Edges: one per unordered tag-pair that co-occurs on >= 1 held rumor,
  #     %{a, b, weight, status} where weight = number of held rumors carrying BOTH tags (drives
  #     thread thickness) and status = the best case status among network/1 cases whose held
  #     rumors produce that pair (crackable > lead > forming > solved, else :unaffiliated).
  #     De-dup pairs by sorted [a, b] the way MapGraph.edges/2 de-dups exits.
  #   Deterministic: nodes sorted by tag asc, edges by sorted-pair asc, so the same held set
  #   always yields the same structure (assert structural props in tests, not content counts).

  # TODO: add entity_web_layout/1, a private helper entity_graph/1 calls to stamp each node with
  #   {cluster, x, y} via a deterministic clustered-radial layout (no physics, server-computed):
  #   1. home cluster per entity = the highest-status network/1 case touching it (tie-break by
  #      case id); entities in no held case -> the :unaffiliated cluster.
  #   2. order clusters by status then id; within a cluster order entities by weight desc, then
  #      tag asc (fully stable ordering).
  #   3. sweep entities around a ring in that combined order so same-case entities land
  #      angularly adjacent (short, bright threads) and cross-case shared entities become the
  #      long bridge threads.
  #   4. nudge each node's radius inward proportional to its weight (bounded so nothing
  #      collapses) so hub entities pull toward center for depth.
  #   Positions live in the same window space MapGraph uses. Same input -> same coordinates.

  defp held_rumors(player) do
    Enum.flat_map(player.rumors, fn id ->
      case Rumor.fetch(id) do
        {:ok, rumor} -> [rumor]
        :error -> []
      end
    end)
  end

  # Whether a connection has already been cracked (its success event is completed).
  defp solved?(player, connection) do
    connection.success_event_id in player.completed_events
  end
end
