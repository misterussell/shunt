alias Shunt.World.Exit

%{
  id: "crossgate_graft_den",
  name: "The Graft Den",

  short_description:
    "Body mods, no questions, no license.",

  description:
    "A converted first aid room that smells of antiseptic and solder. The operating table is a modified cargo pallet. The tools are cleaner than you'd expect. The Syndicate looks the other way because the Graftsman keeps a reliable inventory of what's been installed in whom — useful information.",

  tags: [
    :augmentation,
    :underbelly
  ],

  graph_position: {750, 380},

  npcs: [
    "crossgate_graft_den_stitch"
  ],

  exits: [
    %Exit{
      id: "graft_den_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "graft_den_to_the_pit",
      to: "crossgate_the_pit"
    }
  ]
}
