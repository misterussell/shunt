# Rook: the retired `rook` Hub contact, folded in at his existing desk (shunt9_rooks_desk).
# Rook is already known via the Nickel referral that grants {:knows, "rook"} (which also gates the
# desk), so his BASIC tier reuses that flag — no separate "rook_intro".
# TODO (Rook content pass): author two task events granting {:knowledge, "rook_task1"} /
# "rook_task2" for the mid/best tiers, wire this NPC into shunt9_rooks_desk's :npcs list, and
# delete priv/content/npcs/rook.exs.
%Shunt.World.NPC{
  id: "shunt9_rook",
  name: "Rook",
  contact_key: "rook",
  location_id: "shunt9_rooks_desk",
  story_arcs: [],
  services: [
    %{
      key: :move_goods,
      name: "Move Goods",
      description: "Rook fences whatever you can't unload yourself, for a cut.",
      requirements: [{:knows, "rook"}],
      params: %{sell_fraction: 0.5}
    },
    %{
      key: :move_goods,
      name: "Quiet Channel",
      description: "Rook moves your goods through quieter channels for a better cut.",
      requirements: [{:knows, "rook_task1"}],
      params: %{sell_fraction: 0.65}
    },
    %{
      key: :move_goods,
      name: "Closed-Hands Rate",
      description: "The Syndicate rate — Rook barely takes a cut anymore.",
      requirements: [{:knows, "rook_task2"}],
      params: %{sell_fraction: 0.8}
    }
  ]
}
