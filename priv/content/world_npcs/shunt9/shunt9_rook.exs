# TODO (Rook fold-in): new world-NPC record for the retired `rook` Hub contact, placed at his
# existing desk (shunt9_rooks_desk). Fill in the skeleton below:
#   - description: short in-world blurb (follow docs/SHUNT_STYLE_GUIDE.md).
#   - story_arcs: an intro event + two task events. Rook is ALREADY known via the Nickel referral
#     that grants {:knows, "rook"} (also gates shunt9_rooks_desk), so his BASIC tier reuses that
#     existing flag — no separate "rook_intro" needed. The two task events grant
#     {:knowledge, "rook_task1"} / {:knowledge, "rook_task2"} for the mid/best tiers.
#   - services (see lib/shunt/contacts.ex for shape), key :move_goods, contact_key "rook":
#       basic  requirements [{:knows, "rook"}],       params %{sell_fraction: 0.5}   (today's deal)
#       mid    requirements [{:knows, "rook_task1"}], params %{sell_fraction: 0.65}
#       best   requirements [{:knows, "rook_task2"}], params %{sell_fraction: 0.8}
#     (tune during content pass; basic == today's 0.5 cut.)
#   - Wire this NPC into shunt9_rooks_desk's :npcs list (see that location's TODO).
#   - Delete priv/content/npcs/rook.exs.
# NOTE: contact_key is intentionally omitted below until the struct field is added (see the
# world/npc.ex TODO). Add `contact_key: "rook"` in the same pass that adds the field.
%Shunt.World.NPC{
  id: "shunt9_rook",
  name: "Rook",
  location_id: "shunt9_rooks_desk",
  story_arcs: [],
  services: []
}
