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

  @doc """
  The entity-to-entity "signal web": `%{nodes: [...], edges: [...]}` derived purely from the rumors
  the player holds — the hidden social/political web weaves itself as intel is gathered. The view
  renders one focal entity's neighborhood at a time (see `default_focus/1`), so this stays a plain
  structure with no layout baked in.

    node  %{tag, weight}          weight = number of held rumors carrying the tag
    edge  %{a, b, weight, status} a < b; weight = held rumors carrying both tags; status = the best
          status among cases whose held rumors produce the pair (crackable > lead > forming >
          solved), or `:unaffiliated`
  """
  def entity_graph(player) do
    case held_rumors(player) do
      [] -> %{nodes: [], edges: []}
      held -> %{nodes: nodes(held), edges: edges(held, rumor_status(network(player)))}
    end
  end

  @doc """
  The default focal entity for the web: the highest-signal tag (carried by the most held rumors),
  ties broken alphabetically. `nil` when the graph is empty.
  """
  def default_focus(%{nodes: []}), do: nil

  def default_focus(%{nodes: nodes}),
    do: nodes |> Enum.min_by(&{-&1.weight, &1.tag}) |> Map.fetch!(:tag)

  # One node per distinct held tag, weighted by how many held rumors carry it.
  defp nodes(held) do
    held
    |> Enum.flat_map(& &1.tags)
    |> Enum.frequencies()
    |> Enum.map(fn {tag, weight} -> %{tag: tag, weight: weight} end)
    |> Enum.sort_by(& &1.tag)
  end

  # rumor id -> the best status among held cases containing it.
  defp rumor_status(net) do
    Enum.reduce(net, %{}, fn %{connection: conn, status: status}, acc ->
      Enum.reduce(conn.rumors, acc, fn rid, acc ->
        Map.update(acc, rid, status, &best_status(&1, status))
      end)
    end)
  end

  # One edge per co-occurring tag-pair: weight = how many held rumors carry both, status = the best
  # status among the rumors that produce it. Pairs are de-duped by sorted [a, b].
  defp edges(held, rumor_statuses) do
    held
    |> Enum.flat_map(fn rumor ->
      status = Map.get(rumor_statuses, rumor.id, :unaffiliated)
      Enum.map(tag_pairs(rumor.tags), fn {a, b} -> {a, b, status} end)
    end)
    |> Enum.group_by(fn {a, b, _} -> {a, b} end)
    |> Enum.map(fn {{a, b}, occurrences} ->
      statuses = Enum.map(occurrences, fn {_, _, status} -> status end)
      %{a: a, b: b, weight: length(occurrences), status: Enum.min_by(statuses, &status_rank/1)}
    end)
    |> Enum.sort_by(&{&1.a, &1.b})
  end

  defp tag_pairs(tags) do
    sorted = tags |> Enum.uniq() |> Enum.sort()

    for {a, i} <- Enum.with_index(sorted), b <- Enum.drop(sorted, i + 1), do: {a, b}
  end

  defp best_status(a, b), do: if(status_rank(a) <= status_rank(b), do: a, else: b)
  defp status_rank(:unaffiliated), do: map_size(@status_order)
  defp status_rank(status), do: Map.fetch!(@status_order, status)

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
