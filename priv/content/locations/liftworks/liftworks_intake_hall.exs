alias Shunt.World.Exit

%{
  id: "liftworks_intake_hall",
  name: "Intake Hall",

  short_description:
    "Where the Liftworks sorts who goes up. Clean floors, a slow queue.",

  description:
    "A wide processing floor scrubbed cleaner than anything in the Crossgate. A scan arch spans the only way deeper in, humming steady, and a line of people shuffles toward it clutching papers. Posted notices list tariffs and processing hours in fresh paint. Authority officers work the desks without hurry — nothing here moves free, and nothing here moves fast.",

  tags: [
    :checkpoint,
    :authority,
    :underbelly
  ],

  graph_position: {1350, 150},

  npcs: [
    "liftworks_intake_stamp"
  ],

  events: [
    "liftworks_intake_scan_arch"
  ],

  exits: [
    %Exit{
      id: "intake_hall_to_concourse",
      to: "crossgate_concourse"
    },
    %Exit{
      id: "intake_hall_to_transfer_row",
      to: "liftworks_transfer_row"
    },
    %Exit{
      id: "intake_hall_to_the_pen",
      to: "liftworks_the_pen"
    },
    %Exit{
      id: "intake_hall_to_watch_office",
      to: "liftworks_watch_office"
    },
    %Exit{
      id: "intake_hall_to_the_risers",
      to: "liftworks_the_risers"
    },
    %Exit{
      id: "intake_hall_to_cold_stair",
      to: "liftworks_cold_stair",
      requirements: [
        {:contact_known, "liftworks_proxy"}
      ]
    }
  ]
}
