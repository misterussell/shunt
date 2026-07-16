# TODO (Tally fold-in): new world-NPC record for the retired `tally` Hub contact, placed at the
# Shunt 9 Bazaar (shunt9_bazaar) — her tax-collector/gossip-hub turf. Fill in the skeleton:
#   - description: short in-world blurb (docs/SHUNT_STYLE_GUIDE.md).
#   - story_arcs: intro event granting {:knowledge, "tally_intro"} + two task events granting
#     {:knowledge, "tally_task1"} / "tally_task2".
#   - services (see lib/shunt/contacts.ex), key :settle_the_books, contact_key "tally":
#       basic requirements [{:knows, "tally_intro"}], params %{cost_cred: 1, gain_scrip: 10}  (today's deal)
#       mid   requirements [{:knows, "tally_task1"}], params %{cost_cred: 1, gain_scrip: 16}
#       best  requirements [{:knows, "tally_task2"}], params %{cost_cred: 1, gain_scrip: 24}
#     (tune during content pass; basic == today's numbers.)
#   - Wire into shunt9_bazaar's :npcs list (see that location's TODO).
#   - Delete priv/content/npcs/tally.exs.
# NOTE: contact_key is intentionally omitted below until the struct field is added (see the
# world/npc.ex TODO). Add `contact_key: "tally"` in the same pass that adds the field.
%Shunt.World.NPC{
  id: "shunt9_tally",
  name: "Tally",
  location_id: "shunt9_bazaar",
  story_arcs: [],
  services: []
}
