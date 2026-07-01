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

  # TODO: Closed Hands NPC (the one who extends the credit); a vendor/fencing hook for performed
  # -wealth goods; atmosphere on :book (the row's confidence curdles as debt is called); seed a
  # rumor about who's over-leveraged. This is the shop petal's front and a debt on-ramp.
  npcs: ["bloom_silas"],
  events: [],
  exits: [
    %Exit{id: "gilt_row_to_throat", to: "bloom_throat"},
    %Exit{id: "gilt_row_to_reclaim", to: "bloom_reclaim"},
    %Exit{id: "gilt_row_to_gloss", to: "bloom_gloss"}
  ]
}
