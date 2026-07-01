alias Shunt.World.Exit

%{
  id: "winnow_vestibule",
  name: "The Vestibule",
  short_description:
    "Behind the sealed door — where the quota comes from, and where the shunt completes.",
  description:
    "Past the door the wardens fear is a small, clean, cold room, and it is worse than anything on the Floor because there's nothing in it. No warden, no desk, no master — just a channel in the wall where the quota comes down and the counts go up, a throat for information instead of people. Whatever sets the number isn't here; it's further up, and the Authority is only its hand. Stand in the Vestibule with the shunt in your skull and you can feel it reaching for you — the interface the Bloom's Gloss started, finishing itself, trying to file you like everything else that came up the throat.",
  tags: [:spire, :latticework, :authority],
  graph_position: {3000, -2980},

  # Finale Ghostwork: winnow_vestibule_ice (family ice_authority) lives here, gated on the case
  # (winnow_tier_above). Its deepest reward completes the shunt (winnow_shunt_complete) — the Gloss
  # interface from the Bloom finishing itself, per SHUNT_STORY_CANON.md hook #4 — and confirms the
  # tier above the Authority, opening the way to the Head-End.
  npcs: [],
  events: [],
  exits: [
    %Exit{id: "vestibule_to_gantry", to: "winnow_gantry"},
    # Up to the Head-End once the shunt completes and the channel's been walked back — the first
    # step toward whatever sets the quota.
    %Exit{
      id: "vestibule_to_head_end",
      to: "winnow_head_end",
      requirements: [{:knows, "winnow_shunt_complete"}],
      travel_text: "You follow the channel up, past where the Authority's reach ends."
    }
  ]
}
