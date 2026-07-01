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
        # :churning is granted by working the Web (bloom_yara_market -> bloom_season_stoked).
        {:churning, [{:knows, "bloom_season_stoked"}]}
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
        # :leveraged/:called are granted by Silas's foreclosure chain
        # (bloom_silas_foreclosure -> bloom_silas_called); Reclaim/Gilt Row atmosphere reflects it.
        {:leveraged, [{:knows, "bloom_book_leveraged"}]}
      ]
    }
  }
}
