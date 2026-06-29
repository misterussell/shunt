defmodule Shunt.Web do
  @moduledoc false

  alias Shunt.Web.RumorConnection

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
  skipped. Each entry is `%{cluster, connection, matched, total, lead_ready?}` where
  `lead_ready?` is whether the cluster has reached the connection's `partial_threshold`.

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
        [
          %{
            cluster: cluster,
            connection: conn,
            matched: MapSet.size(cluster),
            total: length(conn.rumors),
            lead_ready?: MapSet.size(cluster) >= conn.partial_threshold
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
    cond do
      not Map.has_key?(board(player)["positions"], id) -> :not_placed
      MapSet.member?(locked_rumor_ids(player), id) -> :solved
      MapSet.member?(resonant_rumor_ids(player), id) -> :resonant
      true -> forming_status(player, id)
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

  defp forming_status(player, id) do
    case Enum.find(warm_clusters(player), &MapSet.member?(&1.cluster, id)) do
      nil -> :on_board
      warm -> {:forming, warm.matched, warm.total}
    end
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
