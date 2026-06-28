%Shunt.World.NPC{
  id: "shunt9_bazaar_nickel",
  name: "Nickel",
  location_id: "shunt9_bazaar",

  story_arcs: [
    "shunt9_bazaar_nickel_intro",
    "shunt9_bazaar_nickel_chits"
    # TODO: append "shunt9_bazaar_nickel_rook" as the third arc so it fires on the next
    # engagement after the "chits" beat. Create the event at
    # priv/content/events/shunt9/bazaar/nickel/rook.exs as a %Shunt.Events.Event{}
    # (id: "shunt9_bazaar_nickel_rook", repeatable: false) where Nickel vouches the player
    # up to Rook (small-time, no-questions fence -> serious fence who "asks where it came
    # from"). on_complete: [{:npc_progression, "shunt9_bazaar_nickel", 1}, {:knowledge,
    # "rook"}]. The {:knowledge, "rook"} satisfies shunt9_rooks_desk's {:knows, "rook"}
    # requirement (requirements.ex:15 / effects.ex:117), which is currently granted nowhere,
    # making Rook's Desk reachable for the first time. Prose must follow docs/SHUNT_*
    # (constitution, style, terminology, lexicon, naming-patterns); match the voice of
    # nickel/intro.exs and nickel/chits.exs.
  ],

  conditional_events: [],

  repeatable_events: [
    "shunt9_bazaar_nickel_heat_banter"
  ]
}
