%{
  id: "stash",
  name: "Stash",
  description:
    "A bolted-down lockbox and a false panel in the wall — somewhere to put what you can't " <>
      "afford to lose and can't carry. The first thing that makes a corner yours.",

  # Tenant (tier 2) keystone. Cheap, class-1; the first upgrade most squatters can afford.
  cost: %{scrip: 40},
  premises_class_min: 1,
  requirements: [],
  effect: %{kind: :gate}
}
