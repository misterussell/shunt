# Rook: the retired `rook` Hub contact, folded in at his existing desk (shunt9_rooks_desk).
# Rook is already known via the Nickel referral that grants {:knows, "rook"} (which also gates the
# desk), so his BASIC tier reuses that flag — no separate "rook_intro".
%Shunt.World.NPC{
  id: "shunt9_rook",
  name: "Rook",
  contact_key: "rook",
  faction: :syndicate_of_closed_hands,
  location_id: "shunt9_rooks_desk",
  story_arcs: ["shunt9_rook_task1", "shunt9_rook_task2"],
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
