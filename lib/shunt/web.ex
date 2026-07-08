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
  the player holds — the hidden social/political web weaves itself as intel is gathered.

    node  %{tag, weight, cluster, x, y}
      weight  = number of held rumors carrying the tag (drives node size)
      cluster = the highest-status network/1 case touching the tag, or `:unaffiliated`
      x, y    = a deterministic clustered-radial position in a normalized unit circle

    edge  %{a, b, weight, status}   (a < b, one per unordered tag-pair)
      weight = number of held rumors carrying BOTH tags (drives thread thickness)
      status = the best status among cases whose held rumors produce the pair
               (crackable > lead > forming > solved), or `:unaffiliated`

  Same held set always yields the same structure and coordinates.
  """
  def entity_graph(player) do
    case held_rumors(player) do
      [] -> %{nodes: [], edges: []}
      held -> build_graph(player, held)
    end
  end

  defp build_graph(player, held) do
    net = network(player)
    held_by_id = Map.new(held, &{&1.id, &1})
    case_status = Map.new(net, fn %{connection: conn, status: status} -> {conn.id, status} end)

    %{
      nodes: layout(node_weights(held), node_clusters(net, held_by_id), case_status),
      edges: edges(held, rumor_status(net))
    }
  end

  # tag -> number of held rumors carrying it.
  defp node_weights(held), do: held |> Enum.flat_map(& &1.tags) |> Enum.frequencies()

  # tag -> the case id of the highest-status held case touching it (best status, then lowest id).
  defp node_clusters(net, held_by_id) do
    net
    |> Enum.flat_map(fn %{connection: conn, status: status} ->
      for rid <- conn.rumors, rumor = held_by_id[rid], rumor != nil, tag <- rumor.tags do
        {tag, {Map.fetch!(@status_order, status), conn.id}}
      end
    end)
    |> Enum.group_by(fn {tag, _} -> tag end, fn {_, ranked} -> ranked end)
    |> Map.new(fn {tag, ranked} -> {tag, elem(Enum.min(ranked), 1)} end)
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

  # Deterministic clustered-radial layout: entities swept around a ring in (cluster, weight, tag)
  # order so same-case entities land adjacent (short, bright threads) and shared entities bridge
  # across; hubs are nudged inward for depth. Coordinates live in a normalized unit circle — the
  # renderer scales them to its viewport.
  defp layout(weights, clusters, case_status) do
    weights
    |> Enum.map(fn {tag, weight} ->
      %{tag: tag, weight: weight, cluster: Map.get(clusters, tag, :unaffiliated)}
    end)
    |> Enum.sort_by(fn node ->
      {cluster_rank(node.cluster, case_status), -node.weight, node.tag}
    end)
    |> place()
  end

  defp place([]), do: []

  defp place(nodes) do
    count = length(nodes)
    max_weight = nodes |> Enum.map(& &1.weight) |> Enum.max()

    nodes
    |> Enum.with_index()
    |> Enum.map(fn {node, i} ->
      theta = 2 * :math.pi() * i / count
      radius = radius_for(node.weight, max_weight)
      Map.merge(node, %{x: radius * :math.cos(theta), y: radius * :math.sin(theta)})
    end)
  end

  # Clusters order by status (best first), then id; :unaffiliated always trails.
  defp cluster_rank(:unaffiliated, _case_status), do: {map_size(@status_order), ""}

  defp cluster_rank(case_id, case_status),
    do: {Map.fetch!(@status_order, Map.fetch!(case_status, case_id)), case_id}

  # Heavier (hub) entities pull toward the center; the lightest ride the rim.
  defp radius_for(_weight, max_weight) when max_weight <= 1, do: 1.0
  defp radius_for(weight, max_weight), do: 1.0 - 0.45 * (weight - 1) / (max_weight - 1)

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
