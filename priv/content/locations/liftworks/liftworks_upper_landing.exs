alias Shunt.World.Exit

# Frontier teaser only. The Upper Landing carries no requirements of its own —
# the three ascent exits from The Risers are the gates. Keeping this location
# ungated is what lets any single key (permit, spoof, or back route) open the way
# up; a location-level requirement would AND against all three and break that.
%{
  id: "liftworks_upper_landing",
  name: "Upper Landing",

  short_description:
    "The lift's far doors. The Midgrid starts here — and stops you here, for now.",

  description:
    "The lift settles and the doors part on a different kind of light: even, white, falling from fixtures that have never been repaired because they have never broken. A clean corridor runs on toward turnstiles, ad-glass, the steady noise of people who pay for quiet. The Midgrid. A guard glances at you, then past you. Not today. But you've stood here now, and the way back down is the only door open.",

  tags: [
    :midgrid,
    :transit
  ],

  graph_position: {1350, -240},

  events: [
    "liftworks_upper_landing_not_today"
  ],

  exits: [
    %Exit{
      id: "upper_landing_to_the_risers",
      to: "liftworks_the_risers"
    }
  ]
}
