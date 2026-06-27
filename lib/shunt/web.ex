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

  # TODO: private board(player) helper returning player.web_board normalized to the
  # %{"positions" => %{}, "wires" => []} shape, so the ops below never have to match missing keys.

  # TODO: board mutation ops, each returning {:ok, [{:web_board, new_board}]} so callers run them
  # through Players.dispatch (which applies the {:web_board, _} effect and persists):
  #   - place_rumor(player, id, x, y): put id => %{"x" => x, "y" => y} into positions (intake -> board)
  #   - move_rumor(player, id, x, y): overwrite positions[id] with new fractional coords
  #   - connect(player, a, b): add Enum.sort([a, b]) to wires unless already present
  #   - disconnect(player, a, b): remove Enum.sort([a, b]) from wires
  #   - return_to_intake(player, id): delete positions[id] and drop every wire that touches id

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
