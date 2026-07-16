# TODO (Nine-Iron fold-in): new world-NPC record for the retired `nine_iron` Hub contact, placed
# at the Watch Office (liftworks_watch_office) — the Authority's room at the first ascent checkpoint.
# Fill in the skeleton:
#   - description: short in-world blurb (docs/SHUNT_STYLE_GUIDE.md).
#   - story_arcs: intro event granting {:knowledge, "nine_iron_intro"} + two task events granting
#     {:knowledge, "nine_iron_task1"} / "nine_iron_task2".
#   - services (see lib/shunt/contacts.ex), key :look_the_other_way, contact_key "nine_iron":
#       basic requirements [{:knows, "nine_iron_intro"}], params %{cost: 20, heat_reduction: 15}  (today's deal)
#       mid   requirements [{:knows, "nine_iron_task1"}], params %{cost: 18, heat_reduction: 22}
#       best  requirements [{:knows, "nine_iron_task2"}], params %{cost: 15, heat_reduction: 30}
#     (tune during content pass; basic == today's numbers.)
#   - Wire into liftworks_watch_office's :npcs list (see that location's TODO).
#   - Delete priv/content/npcs/nine_iron.exs.
# NOTE: contact_key is intentionally omitted below until the struct field is added (see the
# world/npc.ex TODO). Add `contact_key: "nine_iron"` in the same pass that adds the field.
%Shunt.World.NPC{
  id: "liftworks_nine_iron",
  name: "Nine-Iron",
  location_id: "liftworks_watch_office",
  story_arcs: [],
  services: []
}
