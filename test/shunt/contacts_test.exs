defmodule Shunt.ContactsTest do
  # NOTE: keep async: true only if every test reads the REAL loaded world_npcs content. If any
  # test seeds/overrides the global content :ets tables (e.g. injects a fixture contact with
  # services), switch to `async: false` — mutating shared content ETS across async tests flakes.
  use ExUnit.Case, async: true

  # TODO: port the deal-resolver assertions from test/shunt/npcs_test.exs onto
  # Shunt.Contacts.resolve_service/3 (param-driven), covering for each service key:
  #   - happy path effects match the params (scrip/cred/heat/inventory + {:npc_loyalty, contact_key, 5})
  #   - loyalty price/cost multipliers applied at hostile/neutral/favored bands
  #   - roll_reliable? gate -> {:error, :npc_unreliable} when hostile-fail
  #   - insufficient-resource / no-held-item error reasons unchanged
  #   - a locked service (requirements not met) -> {:error, :service_locked}

  # TODO: test list_for_player/1:
  #   - a contact with NO unlocked service is omitted (known-only)
  #   - once the intro flag is granted, the contact appears with only its basic service
  #   - granting a task flag reveals the next tier; locked tiers are absent (hide locked)
  #   - loyalty value on each entry == Loyalty.value(player, contact_key)
end
