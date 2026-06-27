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

  defp board(player) do
    raw = player.web_board || %{}
    %{"positions" => Map.get(raw, "positions", %{}), "wires" => Map.get(raw, "wires", [])}
  end

  # TODO: intake(player): player.rumors -- Map.keys(positions) — rumor ids not yet placed on the board.

  # TODO: clusters(player): connected components over wires, returned as a list of MapSets of rumor
  # ids. Consider only placed rumors (those with a positions entry). A placed rumor with no wires is
  # its own single-element cluster.

  # TODO: resonant_clusters(player): for each cluster whose rumor-set EXACTLY equals an unsolved
  # RumorConnection's rumors (MapSet ==, no extras), return {cluster_ids, connection}. Connections
  # already solved per solved?/2 are excluded. Threshold/partial overlaps return nothing here — the
  # board stays dark on partials (silent partials); only exact matches resonate.

  # TODO: solved?(player, connection): connection.success_event_id in player.completed_events.
end
