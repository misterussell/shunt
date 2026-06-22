%{
  key: "rook",
  name: "Rook",
  faction: :syndicate_of_closed_hands,
  # TODO: remove this static loyalty: field — loyalty now lives on Player.npc_loyalty
  # (per-player), not on the NPC struct. Update lib/shunt/npcs/store.ex's pattern match in
  # the same change.
  loyalty: 40,
  trade_actions: [
    %{
      name: "Move Goods",
      description: "Rook fences whatever you can't unload yourself, for a cut."
    }
  ]
}
