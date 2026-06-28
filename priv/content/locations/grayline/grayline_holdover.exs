alias Shunt.World.Exit

%{
  id: "grayline_holdover",
  name: "The Holdover",

  short_description:
    "The Watch post at the line. Where the grid sets down what it caught.",

  description:
    "A processing room the Midgrid Watch runs at the edge of the Glassline — benches bolted to the floor, a reader at the desk, and a back row of cells the Watch calls holding and everyone else calls the holdover. People taken at the line wait here while the grid decides what they are. The Watch works it like clerks. The Court works it too, quieter, making sure the ones who wait are the ones who tried to skip the Court's price.",

  tags: [
    :midgrid,
    :social
  ],

  graph_position: {2040, -210},

  npcs: [
    "grayline_reyes"
  ],

  exits: [
    %Exit{
      id: "holdover_to_glassline",
      to: "grayline_glassline"
    }
  ]
}
