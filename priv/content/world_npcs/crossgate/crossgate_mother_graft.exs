# Mother Graft: the retired `mother_graft` Hub contact, folded in at the Graft Den
# (crossgate_graft_den). contact_key "mother_graft" preserves the loyalty key.
# TODO (Mother Graft content pass): author an intro event granting {:knowledge, "mother_graft_intro"}
# + two task events granting "mother_graft_task1" / "mother_graft_task2", wire this NPC into
# crossgate_graft_den's :npcs list, and delete priv/content/npcs/mother_graft.exs.
%Shunt.World.NPC{
  id: "crossgate_mother_graft",
  name: "Mother Graft",
  contact_key: "mother_graft",
  faction: :fleshless,
  location_id: "crossgate_graft_den",
  story_arcs: [],
  services: [
    %{
      key: :flesh_tithe,
      name: "Flesh Tithe",
      description: "Mother Graft buys biomod scraps no one else will touch.",
      requirements: [{:knows, "mother_graft_intro"}],
      params: %{input_key: "cracked_bone_plate", gain_scrip: 15, heat: 3}
    },
    %{
      key: :flesh_tithe,
      name: "Clean Cut",
      description: "She pays more, and works cleaner — less heat on the exchange.",
      requirements: [{:knows, "mother_graft_task1"}],
      params: %{input_key: "cracked_bone_plate", gain_scrip: 22, heat: 3}
    },
    %{
      key: :flesh_tithe,
      name: "Fleshless Favor",
      description: "The Fleshless rate — top scrip, almost no trace.",
      requirements: [{:knows, "mother_graft_task2"}],
      params: %{input_key: "cracked_bone_plate", gain_scrip: 30, heat: 2}
    }
  ]
}
