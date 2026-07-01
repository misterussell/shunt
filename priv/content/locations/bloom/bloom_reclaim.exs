alias Shunt.World.Exit

%{
  id: "bloom_reclaim",
  name: "The Reclaim",
  short_description: "Where fallen names pawn their shine and the Closed Hands foreclose.",
  description:
    "The back of Gilt Row, where the gilt comes to die: consignment racks of last season's names, and the desk where the Closed Hands take back what the Bloom couldn't keep paying for. When the book is called, this is where the district goes dark first.",
  tags: [:midgrid, :market],
  graph_position: {3240, -2320},
  atmosphere: [
    %{
      requirements: [],
      text:
        "The consignment racks turn over slow — last season's names pawning this season's shine, the desk patient, the Closed Hands never in a hurry."
    },
    %{
      requirements: [{:district, "bloom", :book, :>=, :leveraged}],
      text:
        "The racks are packed and the desk is busy. The book's coming due across the Bloom, and this is where it lands first — shine sold back for a fraction, names closing out quiet."
    },
    %{
      requirements: [{:district, "bloom", :book, :>=, :called}],
      text:
        "The Reclaim is stripped to the walls, the racks bare, the desk dark. When the book's fully called there's nothing left to reclaim — just the notices, and the cold where a market used to be."
    }
  ],

  # The :book reveal location — its atmosphere goes dark as book -> :called (driven by Silas's
  # foreclosure chain). Connects to the Vent Run (shop-side back-route).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "reclaim_to_gilt_row", to: "bloom_gilt_row"},
    %Exit{id: "reclaim_to_vent_run", to: "bloom_vent_run"}
  ]
}
