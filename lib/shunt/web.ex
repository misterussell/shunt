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
end
