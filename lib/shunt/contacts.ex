defmodule Shunt.Contacts do
  @moduledoc """
  Hub-facing "comms network" layer for contact NPCs.

  A contact is a `%Shunt.World.NPC{}` with a non-empty `services:` list (see
  lib/shunt/world/npc.ex). Contacts are met and built up in the world via their
  `story_arcs` (the ordinary world-NPC event machinery); their *deals* are invoked
  remotely from the Hub through this module. Loyalty/trust is unchanged and keyed by
  the NPC's `contact_key` (see `Shunt.Npcs.Loyalty`).

  ## Service shape (authored in the world-NPC content file)

      %{
        key: :look_the_other_way,          # maps to a resolver clause below
        name: "Look the Other Way",        # Hub button label
        description: "...",                 # Hub blurb
        requirements: [{:knows, "nine_iron_intro"}],  # gates Hub visibility (Shunt.Requirements)
        params: %{cost: 20, heat_reduction: 15}       # tuning consumed by the resolver
      }

  Tiered variants of one deal reuse the same `key` (same resolver) with different
  `params`; each tier's `requirements` flag is granted by an arc milestone event's
  `on_complete` (intro -> basic, task 1 -> mid, task 2 -> best).

  ## Unlock-flag convention

  Service `requirements` use `{:knows, "<contact_key>_intro" | "<contact_key>_task1" | ...}`,
  granted via `{:knowledge, key}` in the corresponding event `on_complete`. (Rook is the
  exception: his basic tier reuses the pre-existing `{:knows, "rook"}` flag granted by the
  Nickel referral event that also gates `shunt9_rooks_desk`.)
  """

  # TODO: def list_for_player(player) -> [%{npc: %Shunt.World.NPC{}, loyalty: 0..100,
  #   services: [service]}] for every world NPC with a non-empty services list whose contact
  #   has >= 1 service with Requirements.met?(player, service.requirements). Include ONLY the
  #   currently-unlocked services per contact (hide locked). Omit contacts with zero unlocked
  #   services (known-only). loyalty = Loyalty.value(player, npc.contact_key). Sort by name.
  #   Source the world NPCs from Shunt.World.Npcs/Content.all(:world_npcs).

  # TODO: def resolve_service(player, contact_key, service_key) -> {:ok, effects} |
  #   {:ok, effects, meta} | {:error, reason}. Look up the contact by contact_key, find the
  #   service by key, verify Requirements.met?(player, service.requirements) (else
  #   {:error, :service_locked}), then dispatch to the keyed resolver with service.params.
  #   Every successful resolver appends {:npc_loyalty, contact_key, @loyalty_gain}. This is the
  #   function HubLive passes to Players.dispatch/2 (curry contact_key + service_key).

  # TODO: port the five deal resolvers from Shunt.Npcs as param-driven private clauses keyed by
  #   service key, preserving the existing math + Loyalty price/cost multipliers + roll_reliable?:
  #     :flesh_tithe      params %{input_key, gain_scrip, heat}  (requires 1x input_key in inventory)
  #     :move_goods       params %{sell_fraction}                (payout = item.sell_value * f * price_mult; clears held_item_key)
  #     :look_the_other_way params %{cost, heat_reduction}       (cost scaled by cost_mult)
  #     :data_drop        params %{cost, gain_cred}
  #     :settle_the_books params %{cost_cred, gain_scrip}
  #   Loyalty lookups/grants key on contact_key (NOT the world-NPC id). Error reasons unchanged:
  #   :npc_unreliable | :insufficient_materials | :insufficient_scrip | :insufficient_cred | :no_held_item.

  # TODO: def can_afford?(player, contact_key, service_key) -> bool, for the Hub to render a
  #   button as :primary vs :dead without running the deal (mirror the old Npcs.can_*?/1 checks,
  #   param-driven). Used only for button styling.

  # TODO: document the new world-NPC authoring fields in docs/SHUNT_DISTRICT_AUTHORING.md —
  #   `contact_key` and the `services` list shape (key/name/description/requirements/params), the
  #   unlock-flag convention, and that a world NPC with services becomes a Hub "comms network"
  #   contact. Keep it in the NPC fields section alongside story_arcs/conditional_events.
end
