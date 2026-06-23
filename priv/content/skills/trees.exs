# TODO: add a `stub:` key to each tree map below — the dormant-page flavor line shown on
# SkillsLive for trees with no gameplay wired up yet (brief §6 page map / §2 "stub pages
# should look intentionally dormant"). Use these exact lines (lifted from the prototype,
# which already nailed the tone):
#   ghostwork:     stub: "No backdoor cracked yet."
#   chrome_meat:   stub: "No table prepped. No hands steady enough yet."
#   web:           stub: "No threads pulled. The Web is listening, not talking."
#   street_alchemy: stub: nil — it's the one fully functional tree, SkillsLive renders its
#     real crafting body instead of the dormant-stub panel, so it never needs this text.
[
  %{
    key: "ghostwork",
    name: "Ghostwork",
    description: "Interfacing with the Latticework — skimming feeds to cracking military ICE.",
    tier_field: :ghostwork_tier,
    tool_key: "jury_rigged_terminal",
    tiers: [
      %{tier: 1, name: "Feed Skimmer"},
      %{tier: 2, name: "Backdoor Runner"},
      %{tier: 3, name: "ICE Cracker"},
      %{tier: 4, name: "Ghost in the Wire"},
      %{tier: 5, name: "Latticework Phantom"}
    ]
  },
  %{
    key: "chrome_meat",
    name: "Chrome & Meat",
    description: "Sourcing, installing, and trading illegal augmentations.",
    tier_field: :chrome_meat_tier,
    tool_key: "patchwork_scalpel",
    tiers: [
      %{tier: 1, name: "Back-Alley Tinkerer"},
      %{tier: 2, name: "Subdermal Installer"},
      %{tier: 3, name: "Augment Smuggler"},
      %{tier: 4, name: "Graftsman's Equal"},
      %{tier: 5, name: "Flesh Made Machine"}
    ]
  },
  %{
    key: "web",
    name: "The Web",
    description: "Reading people, building leverage, calling in favors.",
    tier_field: :web_tier,
    tool_key: "burner_ledger",
    tiers: [
      %{tier: 1, name: "Ear to the Ground"},
      %{tier: 2, name: "Favor Broker"},
      %{tier: 3, name: "Leverage Player"},
      %{tier: 4, name: "Faction Whisperer"},
      %{tier: 5, name: "Web's Center"}
    ]
  },
  %{
    key: "street_alchemy",
    name: "Street Alchemy",
    description: "Breaking down scavenged tech and rebuilding it into something valuable.",
    tier_field: :street_alchemy_tier,
    tool_key: "scrap_forged_soldering_iron",
    tiers: [
      %{tier: 1, name: "Scrap Picker"},
      %{tier: 2, name: "Bench Tinkerer"},
      %{tier: 3, name: "Salvage Artisan"},
      %{tier: 4, name: "Patchworker's Peer"},
      %{tier: 5, name: "Old-World Machinist"}
    ]
  }
]
