# Nine-Iron: the retired `nine_iron` Hub contact, folded in at the Watch Office
# (liftworks_watch_office) — the Authority's room at the first ascent checkpoint. contact_key
# "nine_iron" preserves the loyalty key.
# TODO (Nine-Iron content pass): author an intro event granting {:knowledge, "nine_iron_intro"}
# + two task events granting "nine_iron_task1" / "nine_iron_task2", wire this NPC into
# liftworks_watch_office's :npcs list, and delete priv/content/npcs/nine_iron.exs.
%Shunt.World.NPC{
  id: "liftworks_nine_iron",
  name: "Nine-Iron",
  contact_key: "nine_iron",
  faction: :kaspav_authority,
  location_id: "liftworks_watch_office",
  story_arcs: [],
  services: [
    %{
      key: :look_the_other_way,
      name: "Look the Other Way",
      description: "Nine-Iron keeps the KA off your back, for a price.",
      requirements: [{:knows, "nine_iron_intro"}],
      params: %{cost: 20, heat_reduction: 15}
    },
    %{
      key: :look_the_other_way,
      name: "Lost Report",
      description: "A report that never quite gets filed — deeper heat wipe, lower price.",
      requirements: [{:knows, "nine_iron_task1"}],
      params: %{cost: 18, heat_reduction: 22}
    },
    %{
      key: :look_the_other_way,
      name: "Off the Ledger",
      description: "Nine-Iron scrubs you off the Authority's ledger entirely.",
      requirements: [{:knows, "nine_iron_task2"}],
      params: %{cost: 15, heat_reduction: 30}
    }
  ]
}
