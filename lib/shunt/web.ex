defmodule Shunt.Web do
  @moduledoc false

  alias Shunt.Web.RumorConnection

  @doc """
  Evaluates a player's submitted rumor theory against all authored RumorConnections.

  Returns:
    {:success, event_id}  — submitted set exactly matches a connection's rumors
    {:partial, event_id}  — overlap count >= connection.partial_threshold, not exact
    {:failure, event_id}  — some overlap but below partial_threshold (best candidate wins)
    {:no_match, nil}      — zero overlap with every connection
  """
  def resolve_theory(_player, rumor_ids) do
    submitted = MapSet.new(rumor_ids)

    {result, _best_overlap} =
      Enum.reduce_while(RumorConnection.all(), {{:no_match, nil}, 0}, fn conn,
                                                                         {_best, best_overlap} ->
        required = MapSet.new(conn.rumors)
        overlap = submitted |> MapSet.intersection(required) |> MapSet.size()

        cond do
          submitted == required ->
            {:halt, {{:success, conn.success_event_id}, overlap}}

          overlap >= conn.partial_threshold ->
            {:halt, {{:partial, conn.partial_event_id}, overlap}}

          overlap > best_overlap ->
            {:cont, {{:failure, conn.failure_event_id}, overlap}}

          true ->
            {:cont, {{:no_match, nil}, best_overlap}}
        end
      end)

    result
  end

  @empty_board %{"positions" => %{}, "wires" => []}

  @doc "Clears all positions and wires. Leaves player.rumors untouched (cards return to intake)."
  def wipe_board(_player), do: {:ok, [{:web_board, @empty_board}]}

  @doc """
  Places (or repositions) a rumor on the board at fractional coords. Used for both the
  intake -> board drop and subsequent moves — both just set positions[id].
  """
  def place_rumor(player, id, x, y) do
    board = board(player)
    new_positions = Map.put(board["positions"], id, %{"x" => x, "y" => y})
    {:ok, [{:web_board, %{board | "positions" => new_positions}}]}
  end

  @doc "Wires two rumors together. Stored as a sorted pair; idempotent and order-independent."
  def connect(player, a, b) do
    board = board(player)
    pair = Enum.sort([a, b])
    new_wires = if pair in board["wires"], do: board["wires"], else: board["wires"] ++ [pair]
    {:ok, [{:web_board, %{board | "wires" => new_wires}}]}
  end

  @doc "Removes the wire between two rumors, if present. Order-independent."
  def disconnect(player, a, b) do
    board = board(player)
    new_wires = List.delete(board["wires"], Enum.sort([a, b]))
    {:ok, [{:web_board, %{board | "wires" => new_wires}}]}
  end

  @doc "Pulls a rumor off the board: drops its position and every wire that touches it."
  def return_to_intake(player, id) do
    board = board(player)
    new_positions = Map.delete(board["positions"], id)
    new_wires = Enum.reject(board["wires"], fn [a, b] -> a == id or b == id end)
    {:ok, [{:web_board, %{"positions" => new_positions, "wires" => new_wires}}]}
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

  # Clusters that exactly match an authored connection, as {cluster_set, connection} pairs. Only
  # exact set matches qualify — partial/threshold overlaps are excluded.
  defp matched_clusters(player) do
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
