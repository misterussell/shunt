# Tally: the retired `tally` Hub contact, folded in at the Shunt 9 Bazaar (shunt9_bazaar) — her
# tax-collector / gossip-hub turf. contact_key "tally" preserves the loyalty key.
# TODO (Tally content pass): author an intro event granting {:knowledge, "tally_intro"} + two task
# events granting "tally_task1" / "tally_task2", wire this NPC into shunt9_bazaar's :npcs list, and
# delete priv/content/npcs/tally.exs.
%Shunt.World.NPC{
  id: "shunt9_tally",
  name: "Tally",
  contact_key: "tally",
  location_id: "shunt9_bazaar",
  story_arcs: [],
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
