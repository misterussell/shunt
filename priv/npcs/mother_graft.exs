%{
  key: "mother_graft",
  name: "Mother Graft",
  faction: :fleshless,
  # TODO: remove this static loyalty: field — loyalty now lives on Player.npc_loyalty
  # (per-player), not on the NPC struct. Update lib/shunt/npcs/store.ex's pattern match in
  # the same change.
  loyalty: 20,
  trade_actions: [
    %{
      name: "Flesh Tithe",
      description: "Mother Graft buys biomod scraps no one else will touch."
    }
  ]
}
