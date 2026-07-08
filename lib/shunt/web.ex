defmodule Shunt.Web do
  @moduledoc false

  alias Shunt.Events
  alias Shunt.Web.Rumor
  alias Shunt.Web.RumorConnection

  # TODO: [domain-network-cleanup] Once WebLive no longer calls the old board API, DELETE the entire
  # wire/board layer below `pursue`: @empty_board, wipe_board, place_rumor, connect, disconnect,
  # return_to_intake, intake, placed, wires, clusters, matched_clusters, resonant_clusters,
  # solved_clusters, warm_clusters, rumor_status/2+/5, locked_rumor_ids, best_partial_connection,
  # resonant_rumor_ids, locked?/locked_either?, board, reachable — and delete the now-obsolete
  # test/shunt/web_board_test.exs and test/shunt/web_warmth_test.exs. network/1, pursue/3,
  # entities/1, entity_view/2 (covered in web_network_test.exs) replace all of it.

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
  doesn't qualify (`:solved`, `:insufficient_intel`, or `:lead_spent`).
  """
  def pursue(player, connection_id, mode) do
    conn = RumorConnection.fetch!(connection_id)

    with :ok <- validate_pursuit(player, conn, mode) do
      {event_id, heat} = pursuit_target(conn, mode)
      {:ok, event_effects, _meta} = Events.start(player, event_id)
      {:ok, [{:heat, heat} | event_effects], %{event_id: event_id}}
    end
  end

  defp pursuit_target(conn, :crack), do: {conn.success_event_id, conn.crack_heat}
  defp pursuit_target(conn, :lead), do: {conn.partial_event_id, conn.lead_heat}

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

  defp held_rumors(player) do
    Enum.flat_map(player.rumors, fn id ->
      case Rumor.fetch(id) do
        {:ok, rumor} -> [rumor]
        :error -> []
      end
    end)
  end

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

  @empty_board %{"positions" => %{}, "wires" => []}

  @doc "Clears all positions and wires. Leaves player.rumors untouched (cards return to intake)."
  def wipe_board(_player), do: {:ok, [{:web_board, @empty_board}]}

  @doc """
  Places (or repositions) a rumor on the board at fractional coords. Used for both the
  intake -> board drop and subsequent moves — both just set positions[id].
  """
  def place_rumor(player, id, x, y) do
    cond do
      # Only rumors the player actually holds may go on the board — otherwise a client could place
      # (and resonate) a connection's rumors it never collected, since clusters read board state.
      id not in player.rumors ->
        {:ok, []}

      locked?(player, id) ->
        {:ok, []}

      true ->
        board = board(player)
        new_positions = Map.put(board["positions"], id, %{"x" => x, "y" => y})
        {:ok, [{:web_board, %{board | "positions" => new_positions}}]}
    end
  end

  @doc "Wires two rumors together. Stored as a sorted pair; idempotent and order-independent."
  def connect(player, a, b) do
    if locked_either?(player, a, b) do
      {:ok, []}
    else
      board = board(player)
      pair = Enum.sort([a, b])
      new_wires = if pair in board["wires"], do: board["wires"], else: board["wires"] ++ [pair]
      {:ok, [{:web_board, %{board | "wires" => new_wires}}]}
    end
  end

  @doc "Removes the wire between two rumors, if present. Order-independent."
  def disconnect(player, a, b) do
    if locked_either?(player, a, b) do
      {:ok, []}
    else
      board = board(player)
      new_wires = List.delete(board["wires"], Enum.sort([a, b]))
      {:ok, [{:web_board, %{board | "wires" => new_wires}}]}
    end
  end

  @doc "Pulls a rumor off the board: drops its position and every wire that touches it."
  def return_to_intake(player, id) do
    if locked?(player, id) do
      {:ok, []}
    else
      board = board(player)
      new_positions = Map.delete(board["positions"], id)
      new_wires = Enum.reject(board["wires"], fn [a, b] -> a == id or b == id end)
      {:ok, [{:web_board, %{"positions" => new_positions, "wires" => new_wires}}]}
    end
  end

  @doc "Rumors the player holds that are not yet placed on the board (the intake tray)."
  def intake(player) do
    player.rumors -- Map.keys(board(player)["positions"])
  end

  @doc "Placed rumors as {id, x, y} tuples (fractional coords), sorted by id."
  def placed(player) do
    board(player)["positions"]
    |> Enum.map(fn {id, %{"x" => x, "y" => y}} -> {id, x, y} end)
    |> Enum.sort()
  end

  @doc "The board's wire pairs."
  def wires(player), do: board(player)["wires"]

  @doc """
  Connected components of the board, as a list of MapSets of rumor ids. Only placed rumors are
  considered; a wire with an unplaced endpoint is ignored. A placed rumor with no wires is its
  own single-element cluster.
  """
  def clusters(player) do
    board = board(player)
    placed = MapSet.new(Map.keys(board["positions"]))

    adjacency =
      board["wires"]
      |> Enum.filter(fn [a, b] -> MapSet.member?(placed, a) and MapSet.member?(placed, b) end)
      |> Enum.reduce(%{}, fn [a, b], acc ->
        acc |> Map.update(a, [b], &[b | &1]) |> Map.update(b, [a], &[a | &1])
      end)

    {components, _seen} =
      Enum.reduce(placed, {[], MapSet.new()}, fn node, {components, seen} ->
        if MapSet.member?(seen, node) do
          {components, seen}
        else
          component = reachable(MapSet.new([node]), [node], adjacency)
          {[component | components], MapSet.union(seen, component)}
        end
      end)

    components
  end

  @doc """
  Clusters that exactly match an unsolved connection, as {cluster_set, connection} pairs. Only
  exact set matches resonate — partial/threshold overlaps return nothing (the board stays dark on
  near-misses).
  """
  def resonant_clusters(player) do
    player
    |> matched_clusters()
    |> Enum.reject(fn {_cluster, conn} -> solved?(player, conn) end)
  end

  @doc """
  Clusters that exactly match an already-cracked connection, as a list of MapSets. These are the
  solved cases — stamped and locked on the board.
  """
  def solved_clusters(player) do
    player
    |> matched_clusters()
    |> Enum.filter(fn {_cluster, conn} -> solved?(player, conn) end)
    |> Enum.map(fn {cluster, _conn} -> cluster end)
  end

  @doc """
  Clusters that exactly match an authored connection, as {cluster_set, connection} pairs (solved
  and unsolved alike). Only exact set matches qualify — partial/threshold overlaps are excluded.
  Callers that need both the resonant and solved partitions should compute this once and split on
  `solved?/2` rather than calling `resonant_clusters/1` and `solved_clusters/1` separately.
  """
  def matched_clusters(player) do
    connections = RumorConnection.all()

    player
    |> clusters()
    |> Enum.flat_map(fn cluster ->
      case Enum.find(connections, &(MapSet.new(&1.rumors) == cluster)) do
        nil -> []
        conn -> [{cluster, conn}]
      end
    end)
  end

  @doc "Whether a connection has already been cracked (its success event is completed)."
  def solved?(player, connection) do
    connection.success_event_id in player.completed_events
  end

  @doc """
  Rumor ids that belong to a solved (locked) cluster. Mutating board ops refuse to touch these,
  so a cracked case stays stamped and intact even if a stale or out-of-band board event arrives
  (the JS hook also blocks the gesture, but the server is the source of truth).
  """
  def locked_rumor_ids(player) do
    player
    |> solved_clusters()
    |> Enum.reduce(MapSet.new(), &MapSet.union(&2, &1))
  end

  @doc """
  Warm (near-miss) clusters, as a list of maps. A cluster is warm toward a connection when its
  rumor set is a *proper* subset of that connection's rumors and holds at least two — so a lone
  placed card and an exact (resonant) match are both excluded. Already-solved connections are
  skipped. Each entry is `%{cluster, connection, matched, total, short, lead_ready?}` where
  `short` is how many rumors the cluster is still shy of the full set, and `lead_ready?` is
  whether the cluster has reached the connection's `partial_threshold` *and* its
  `partial_event_id` has not already been followed — a non-repeatable partial drops out of
  lead-ready once completed, so the lead can't be re-followed into an already-finished event.

  This is the shared partial-match primitive: the dossier's "in play" status and the leads strip
  both read it.
  """
  def warm_clusters(player) do
    connections = RumorConnection.all()

    player
    |> clusters()
    |> Enum.flat_map(fn cluster ->
      with true <- MapSet.size(cluster) >= 2,
           conn when not is_nil(conn) <- best_partial_connection(player, cluster, connections) do
        matched = MapSet.size(cluster)
        total = length(conn.rumors)

        [
          %{
            cluster: cluster,
            connection: conn,
            matched: matched,
            total: total,
            short: total - matched,
            lead_ready?:
              matched >= conn.partial_threshold and
                conn.partial_event_id not in player.completed_events
          }
        ]
      else
        _ -> []
      end
    end)
  end

  @doc """
  A placed rumor's board state for the dossier "in play" line:

    * `:not_placed` — held but not on the board
    * `:on_board` — placed, in no warm/resonant/solved cluster
    * `{:forming, matched, total}` — in a warm cluster
    * `:resonant` — in an exact, unsolved cluster
    * `:solved` — in a solved cluster
  """
  def rumor_status(player, id) do
    rumor_status(
      player,
      id,
      locked_rumor_ids(player),
      resonant_rumor_ids(player),
      warm_clusters(player)
    )
  end

  @doc """
  `rumor_status/2` against an already-computed board breakdown — the locked (solved) and
  resonant id sets and the warm-cluster list. Callers that just built those (the board LiveView)
  pass them in so the status line doesn't re-walk the graph and reload connections for each open
  dossier.
  """
  def rumor_status(player, id, solved_ids, resonant_ids, warm) do
    cond do
      not Map.has_key?(board(player)["positions"], id) ->
        :not_placed

      MapSet.member?(solved_ids, id) ->
        :solved

      MapSet.member?(resonant_ids, id) ->
        :resonant

      true ->
        case Enum.find(warm, &MapSet.member?(&1.cluster, id)) do
          nil -> :on_board
          warm_cluster -> {:forming, warm_cluster.matched, warm_cluster.total}
        end
    end
  end

  # The closest connection a cluster is a proper subset of (smallest total = highest match ratio,
  # since the matched count is fixed at the cluster size), excluding solved connections. nil when
  # the cluster is not a partial of any unsolved connection.
  defp best_partial_connection(player, cluster, connections) do
    connections
    |> Enum.filter(fn conn ->
      conn_set = MapSet.new(conn.rumors)

      MapSet.subset?(cluster, conn_set) and MapSet.size(cluster) < MapSet.size(conn_set) and
        not solved?(player, conn)
    end)
    |> Enum.min_by(&length(&1.rumors), fn -> nil end)
  end

  defp resonant_rumor_ids(player) do
    player
    |> resonant_clusters()
    |> Enum.reduce(MapSet.new(), fn {cluster, _conn}, acc -> MapSet.union(acc, cluster) end)
  end

  defp locked?(player, id), do: MapSet.member?(locked_rumor_ids(player), id)

  defp locked_either?(player, a, b) do
    locked = locked_rumor_ids(player)
    MapSet.member?(locked, a) or MapSet.member?(locked, b)
  end

  defp board(player) do
    raw = player.web_board || %{}
    %{"positions" => Map.get(raw, "positions", %{}), "wires" => Map.get(raw, "wires", [])}
  end

  defp reachable(seen, [], _adjacency), do: seen

  defp reachable(seen, [node | queue], adjacency) do
    fresh = adjacency |> Map.get(node, []) |> Enum.reject(&MapSet.member?(seen, &1))
    reachable(MapSet.union(seen, MapSet.new(fresh)), queue ++ fresh, adjacency)
  end
end
