defmodule Shunt.Skills.Catalog do
  @moduledoc false

  @trees [
    %{
      key: "ghostwork",
      name: "Ghostwork",
      description: "Interfacing with the Latticework — skimming feeds to cracking military ICE.",
      tier_field: :ghostwork_tier,
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
      tiers: [
        %{tier: 1, name: "Scrap Picker"},
        %{tier: 2, name: "Bench Tinkerer"},
        %{tier: 3, name: "Salvage Artisan"},
        %{tier: 4, name: "Patchworker's Peer"},
        %{tier: 5, name: "Old-World Machinist"}
      ]
    }
  ]

  def trees, do: @trees

  def current_tier(player, tree), do: Map.fetch!(player, tree.tier_field)
end
