alias Shunt.World.Exit

%{
  id: "bloom_gilt_row",
  name: "Gilt Row",
  short_description:
    "The boutique arcade — where you buy the look, and the Closed Hands hold the paper.",
  description:
    "A row of bright frontages selling the surface of wealth: cut crystal, reclaimed velvet, light fitted to flatter. Almost none of it is paid for outright. Behind every counter the Closed Hands keep the ledger on what the shine really costs.",
  tags: [:midgrid, :market, :social],
  graph_position: {3210, -2170},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The arcade glows, every frontage bright with things almost nobody's paid for outright, the confidence thick enough to lean on."
    },
    %{
      requirements: [{:district, "bloom", :book, :>=, :leveraged}],
      text:
        "The shine's got a nervous edge now. Too many names came due at once, and you can see it in how hard the frontages are working to look untroubled."
    },
    %{
      requirements: [{:district, "bloom", :book, :>=, :called}],
      text:
        "Half the frontages are dark, shuttered overnight, the Closed Hands' notices on the glass. The gilt that's left burns brighter to cover the gaps, and fools no one."
    }
  ],
  npcs: ["bloom_silas"],
  events: [],
  exits: [
    %Exit{id: "gilt_row_to_throat", to: "bloom_throat"},
    %Exit{id: "gilt_row_to_reclaim", to: "bloom_reclaim"},
    %Exit{id: "gilt_row_to_gloss", to: "bloom_gloss"}
  ]
}
