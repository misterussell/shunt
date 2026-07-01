%Shunt.District.Def{
  id: "bloom",
  name: "The Bloom",
  facts: %{
    # The Spire's pull through the throat — one meter doing double duty: more draw = the Bloom
    # blazes and money flows, AND the throat takes people faster. Rises as the player clears the
    # clogged exhaust ducts (Street Alchemy repairables in the Vent Run) and learns to work the
    # vents. The Expose ending grants "bloom_throat_starved", which sits at the TOP of the rule
    # list so it forces the fact back to :slack regardless of duct repairs — the throat can't pull,
    # the harvest stops. Derived only from repairs + knowledge, never stored.
    draw: %{
      kind: :ordinal,
      levels: [:slack, :drawing, :gorging],
      default: :slack,
      rules: [
        {:slack, [{:knows, "bloom_throat_starved"}]},
        # Both Vent Run ducts fully repaired = the flower burns at the top of its lungs.
        {:gorging,
         [
           {:infra_state, "bloom_intake_duct", "repaired"},
           {:infra_state, "bloom_flare_manifold", "repaired"}
         ]},
        # Any duct brought back at all (patched or repaired) gets the bleed flowing = drawing.
        {:drawing, [{:infra_state, "bloom_intake_duct", "repaired"}]},
        {:drawing, [{:infra_state, "bloom_intake_duct", "patched"}]},
        {:drawing, [{:infra_state, "bloom_flare_manifold", "repaired"}]},
        {:drawing, [{:infra_state, "bloom_flare_manifold", "patched"}]}
      ]
    },
    # The rumor mill's heat (Whisper Syndicate). Gilded = polite, nobody talks; cascade = a
    # scandal-storm where names are falling. Rises as the player surfaces rumors; the Expose
    # ending slams it to :cascade. Scales the Skim Crew income module.
    season: %{
      kind: :ordinal,
      levels: [:gilded, :churning, :cascade],
      default: :gilded,
      rules: [
        {:cascade, [{:knows, "bloom_season_cascade"}]},
        {:churning, [{:knows, "bloom_season_stoked"}]}
        # TODO: decide whether :churning should derive from a knowledge flag granted by a
        # mid-investigation event (current stub) or directly from {:has_rumor, key} once enough
        # Bloom rumors are held. Finalize when the rumors + Slate events are authored.
      ]
    },
    # The debt weighing on the district (Closed Hands). Flush -> leveraged -> called; at :called,
    # venues go dark (the Reclaim and a called Gilt Row / Floor room shutter). The physical
    # counterweight to :draw — the brighter it burns, the deeper it's leveraged.
    book: %{
      kind: :ordinal,
      levels: [:flush, :leveraged, :called],
      default: :flush,
      rules: [
        {:called, [{:knows, "bloom_book_called"}]},
        {:leveraged, [{:knows, "bloom_book_leveraged"}]}
        # TODO: tie :called to the infra_state of the shuttered venues so a foreclosed room reads
        # as dark on the map, e.g. {:called, [{:infra_state, "bloom_reclaim_floor", "broken"}]}.
        # Finalize once the Reclaim / Gilt Row repairables (or dark-location gating) are authored.
      ]
    }
  }
}
