%{
  key: "nine_iron",
  name: "Nine-Iron",
  faction: :kaspav_authority,
  # TODO: remove this static loyalty: field — loyalty now lives on Player.npc_loyalty
  # (per-player), not on the NPC struct. Update lib/shunt/npcs/store.ex's pattern match in
  # the same change.
  loyalty: 15,
  trade_actions: [
    %{
      name: "Look the Other Way",
      description: "Nine-Iron keeps the KA off your back, for a price."
    }
  ]
}
