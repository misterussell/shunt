alias Shunt.World.Exit

%{
  id: "bloom_reclaim",
  name: "The Reclaim",
  short_description: "Where fallen names pawn their shine and the Closed Hands foreclose.",
  description:
    "The back of Gilt Row, where the gilt comes to die: consignment racks of last season's names, and the desk where the Closed Hands take back what the Bloom couldn't keep paying for. When the book is called, this is where the district goes dark first.",
  tags: [:midgrid, :market],
  graph_position: {3240, -2320},

  # TODO: the :book reveal location — author it to go dark when book hits :called (a repairable
  # "bloom_reclaim_floor" whose "broken" state feeds the district :called rule, or location-level
  # gating). Closed Hands foreclosure event; grants toward "bloom_book_leveraged"/"bloom_book_called".
  # Connects to the Vent Run (shop-side back-route).
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "reclaim_to_gilt_row", to: "bloom_gilt_row"},
    %Exit{id: "reclaim_to_vent_run", to: "bloom_vent_run"}
  ]
}
