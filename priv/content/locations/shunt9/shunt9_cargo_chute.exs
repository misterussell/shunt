alias Shunt.World.Exit

%{
  id: "shunt9_cargo_chute",
  name: "Cargo Chute",

  short_description:
    "A disused freight chute Juno's crew uses to move goods unseen.",

  description:
    "A steep maintenance chute that once fed freight down to the lower platforms. Juno's people rigged it back into service with a winch and a lot of nerve. She only points it out to runners she trusts to keep their mouths shut.",

  tags: [
    :infrastructure,
    :underbelly
  ],

  graph_position: {350, 480},

  exits: [
    %Exit{
      id: "cargo_chute_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
