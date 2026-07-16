# TODO (Mother Graft fold-in): new world-NPC record for the retired `mother_graft` Hub contact,
# placed at the Graft Den (crossgate_graft_den). Fill in the skeleton:
#   - description: short in-world blurb (docs/SHUNT_STYLE_GUIDE.md).
#   - story_arcs: intro event granting {:knowledge, "mother_graft_intro"} + two task events
#     granting {:knowledge, "mother_graft_task1"} / "mother_graft_task2".
#   - services (see lib/shunt/contacts.ex), key :flesh_tithe, contact_key "mother_graft":
#       basic requirements [{:knows, "mother_graft_intro"}],
#             params %{input_key: "cracked_bone_plate", gain_scrip: 15, heat: 3}  (today's deal)
#       mid   requirements [{:knows, "mother_graft_task1"}], params %{... gain_scrip: 22, heat: 3}
#       best  requirements [{:knows, "mother_graft_task2"}], params %{... gain_scrip: 30, heat: 2}
#     (tune during content pass; basic == today's numbers.)
#   - Wire into crossgate_graft_den's :npcs list (see that location's TODO).
#   - Delete priv/content/npcs/mother_graft.exs.
# NOTE: contact_key is intentionally omitted below until the struct field is added (see the
# world/npc.ex TODO). Add `contact_key: "mother_graft"` in the same pass that adds the field.
%Shunt.World.NPC{
  id: "crossgate_mother_graft",
  name: "Mother Graft",
  location_id: "crossgate_graft_den",
  story_arcs: [],
  services: []
}
