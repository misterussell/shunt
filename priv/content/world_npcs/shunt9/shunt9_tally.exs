# Tally: the retired `tally` Hub contact, folded in at the Shunt 9 Bazaar (shunt9_bazaar) — her
# tax-collector / gossip-hub turf. contact_key "tally" preserves the loyalty key. The story arc
# gates the Settle the Books service tiers: intro grants "tally_intro" (basic), then the two task
# events grant "tally_task1"/"tally_task2" (mid/best).
%Shunt.World.NPC{
  id: "shunt9_tally",
  name: "Tally",
  contact_key: "tally",
  faction: :syndicate_of_closed_hands,
  location_id: "shunt9_bazaar",
  story_arcs: [
    "shunt9_tally_intro",
    "shunt9_tally_task1",
    "shunt9_tally_task2"
  ],
  services: [
    %{
      key: :settle_the_books,
      name: "Settle the Books",
      description: "Tally squares your debts with the Syndicate for a cred.",
      requirements: [{:knows, "tally_intro"}],
      params: %{cost_cred: 1, gain_scrip: 10}
    },
    %{
      key: :settle_the_books,
      name: "Creative Accounting",
      description: "Tally finds scrip in the margins others miss.",
      requirements: [{:knows, "tally_task1"}],
      params: %{cost_cred: 1, gain_scrip: 16}
    },
    %{
      key: :settle_the_books,
      name: "Cook the Ledger",
      description: "The whole ledger bends your way — Tally's best rate.",
      requirements: [{:knows, "tally_task2"}],
      params: %{cost_cred: 1, gain_scrip: 24}
    }
  ]
}
