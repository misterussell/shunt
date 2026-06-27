alias Shunt.World.Exit

%{
  id: "crossgate_house_of_closed_hands",
  name: "House of Closed Hands",

  short_description:
    "The Syndicate's seat in The Crossgate. You were invited.",

  description:
    "A fortified section of the interchange's original administrative block — actual walls, actual doors, actual locks that work. The symbol of the closed fist is pressed into every surface in here, but subtly. This is not a place that needs to announce itself. The Syndicate does not maintain a front. It maintains a fact.",

  tags: [
    :syndicate,
    :restricted
  ],

  requirements: [
    {:knows, "crossgate_house_entry_granted"}
  ],

  graph_position: {1050, 530},

  npcs: [
    "crossgate_house_strand"
  ],

  exits: [
    %Exit{
      id: "house_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "house_to_counting_house",
      to: "crossgate_counting_house"
    }
  ]
}
