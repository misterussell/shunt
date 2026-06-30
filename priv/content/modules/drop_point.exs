%{
  id: "drop_point",
  name: "Drop Point",
  description:
    "A marked dead-drop and a back way in that the right people learn without being told. " <>
      "Work starts coming to you instead of the other way round.",

  # Fixture (tier 4) keystone. Needs the room a real safehouse gives, hence class-2.
  cost: %{scrip: 120, cred: 15},
  premises_class_min: 2,
  requirements: [],
  effect: %{kind: :gate}
}
