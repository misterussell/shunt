alias Shunt.World.Exit

%{
  id: "liftworks_watch_office",
  name: "Watch Office",

  short_description:
    "The Authority's room. Screens, records, and a terminal that talks to the Latticework.",

  description:
    "A glassed-in office overlooking the intake floor. Screens cycle through the queue, the scan arch feed, and a watchlist that scrolls too fast to read. The duty officer rarely looks up. A records terminal in the corner ties the whole checkpoint into the Latticework — every permit issued, every tag flagged, all of it written down somewhere a careful person could reach.",

  tags: [
    :authority,
    :latticework,
    :underbelly
  ],

  graph_position: {1500, -90},

  npcs: [
    "liftworks_writ"
  ],

  events: [
    "liftworks_watch_office_terminal",
    "liftworks_watch_office_pressure"
  ],

  exits: [
    %Exit{
      id: "watch_office_to_intake_hall",
      to: "liftworks_intake_hall"
    }
  ]
}
