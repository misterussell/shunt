%{
  key: "tally",
  name: "Tally",
  faction: :syndicate_of_closed_hands,
  # TODO: remove this static loyalty: field — loyalty now lives on Player.npc_loyalty
  # (per-player), not on the NPC struct. Update lib/shunt/npcs/store.ex's pattern match in
  # the same change.
  loyalty: 55,
  trade_actions: [
    %{
      name: "Settle the Books",
      description: "Tally is Shunt 9's de facto tax collector and gossip hub."
    }
  ]
}
