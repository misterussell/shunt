defmodule Shunt.Skills.Catalog do
  @moduledoc false

  # TODO: define @trees, a list of 4 maps, one per skill tree, each shaped as:
  #   %{
  #     key: "ghostwork",
  #     name: "Ghostwork",
  #     description: "Interfacing with the Latticework — skimming feeds to cracking military ICE.",
  #     tier_field: :ghostwork_tier,
  #     tiers: [
  #       %{tier: 1, name: "Feed Skimmer"},
  #       %{tier: 2, name: "Backdoor Runner"},
  #       %{tier: 3, name: "ICE Cracker"},
  #       %{tier: 4, name: "Ghost in the Wire"},
  #       %{tier: 5, name: "Latticework Phantom"}
  #     ]
  #   }
  # The other 3 trees, same shape:
  #   chrome_meat / "Chrome & Meat" / :chrome_meat_tier /
  #     "Sourcing, installing, and trading illegal augmentations." / tiers:
  #     1 "Back-Alley Tinkerer", 2 "Subdermal Installer", 3 "Augment Smuggler",
  #     4 "Graftsman's Equal", 5 "Flesh Made Machine"
  #   web / "The Web" / :web_tier /
  #     "Reading people, building leverage, calling in favors." / tiers:
  #     1 "Ear to the Ground", 2 "Favor Broker", 3 "Leverage Player",
  #     4 "Faction Whisperer", 5 "Web's Center"
  #   street_alchemy / "Street Alchemy" / :street_alchemy_tier /
  #     "Breaking down scavenged tech and rebuilding it into something valuable." / tiers:
  #     1 "Scrap Picker", 2 "Bench Tinkerer", 3 "Salvage Artisan",
  #     4 "Patchworker's Peer", 5 "Old-World Machinist"

  # TODO: def trees, do: @trees

  # TODO: def current_tier(player, tree), do: Map.fetch!(player, tree.tier_field)
  # (player is a %Shunt.Players.Player{}, tree is one of the maps from trees/0)
end
