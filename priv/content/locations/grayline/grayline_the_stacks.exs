alias Shunt.World.Exit

%{
  id: "grayline_the_stacks",
  name: "The Stacks",

  short_description:
    "The Court's back room, where the templates live and echoes get written in.",

  description:
    "Past the counter, past the door that isn't for clients: rows of cold storage and one current-spec terminal wired straight into the Midgrid registry. This is where a name stops being paper and becomes record — where the Court reaches into the grid's own memory and adds a person who was never there. Cal told you how the seam opens. Standing in front of it is a different thing than hearing about it.",

  tags: [
    :midgrid,
    :latticework
  ],

  graph_position: {1960, -380},

  exits: [
    %Exit{
      id: "stacks_to_echo_court",
      to: "grayline_echo_court"
    }
  ]
}
