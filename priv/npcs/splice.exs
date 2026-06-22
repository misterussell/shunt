%{
  key: "splice",
  name: "Splice",
  faction: :latticework_collective,
  # TODO: remove this static loyalty: field — loyalty now lives on Player.npc_loyalty
  # (per-player), not on the NPC struct. Update lib/shunt/npcs/store.ex's pattern match in
  # the same change.
  loyalty: 25,
  trade_actions: [
    %{
      name: "Data Drop",
      description: "Splice trades scraps of Latticework intel for whatever you can spare."
    }
  ]
}
