# Splice: the retired `splice` Hub contact, folded into this existing world NPC. contact_key
# "splice" preserves the loyalty key; the struct id stays district-prefixed.
# TODO (Splice content pass): author the arc that grants the service unlock flags — reuse
# liftworks_splice_blind_spot as the intro (its on_complete grants {:knowledge, "splice_intro"}),
# then add two task events granting "splice_task1" / "splice_task2". Delete priv/content/npcs/splice.exs.
%Shunt.World.NPC{
  id: "liftworks_splice",
  name: "Splice",
  contact_key: "splice",
  location_id: "liftworks_transfer_row",
  story_arcs: [
    "liftworks_splice_blind_spot"
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
