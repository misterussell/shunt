defmodule Shunt.Web do
  @moduledoc false

  alias Shunt.Web.RumorConnection

  # TODO: implement resolve_theory(player, rumor_ids) → {:success | :partial | :failure | :no_match, event_id | nil}
  # Walk RumorConnection.all/0. For each connection:
  #   submitted = MapSet.new(rumor_ids)
  #   required  = MapSet.new(connection.rumors)
  #   if submitted == required                                        → {:success, connection.success_event_id}
  #   if MapSet.intersection(submitted, required) |> MapSet.size()
  #      >= connection.partial_threshold                              → {:partial, connection.partial_event_id}
  # If no connection matches at success or partial level             → {:failure, connection.failure_event_id}
  # of the best partial candidate (most overlap); if no candidate
  # at all (zero overlap with every connection)                      → {:no_match, nil}
  # Use Enum.reduce_while/3: return {:halt, result} on success,
  # accumulate best partial candidate, then return it or :no_match.
end
