# Splice: the retired `splice` Hub contact, folded into this existing world NPC. contact_key
# "splice" preserves the loyalty key; the struct id stays district-prefixed. The story arc gates
# the Data Drop service tiers: blind_spot grants "splice_intro" (basic), then the two task events
# grant "splice_task1"/"splice_task2" (mid/best).
%Shunt.World.NPC{
  id: "liftworks_splice",
  name: "Splice",
  contact_key: "splice",
  faction: :latticework_collective,
  location_id: "liftworks_transfer_row",
  story_arcs: [
    "liftworks_splice_blind_spot",
    "liftworks_splice_task1",
    "liftworks_splice_task2"
  ],
  services: [
    %{
      key: :data_drop,
      name: "Data Drop",
      description: "Splice trades scraps of Latticework intel for whatever you can spare.",
      requirements: [{:knows, "splice_intro"}],
      params: %{cost: 20, gain_cred: 1}
    },
    %{
      key: :data_drop,
      name: "Deep Cache",
      description: "A fatter pull from Splice's private caches.",
      requirements: [{:knows, "splice_task1"}],
      params: %{cost: 15, gain_cred: 2}
    },
    %{
      key: :data_drop,
      name: "Blind-Spot Feed",
      description: "Splice routes you intel straight through the scan-arch blind spot.",
      requirements: [{:knows, "splice_task2"}],
      params: %{cost: 15, gain_cred: 3}
    }
  ]
}
