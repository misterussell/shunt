%Shunt.Ghostwork.IceNode{
  id: "winnow_line_ice",
  name: "The Pace Channel",
  family: "ice_authority",
  location_id: "winnow_sorting_floor",
  description:
    "The sorting line takes its pace and its quota from a channel that runs off the Floor entirely — up past the wardens, to wherever the number is written. Get behind it and you can read the orders coming down. The wardens would burn you for looking. They're more afraid of the channel than they are of you.",
  requirements: [
    {:knows, "winnow_line_ice_found"}
  ],
  cool_threshold: 70,
  layers: [
    %{
      id: "belt_face",
      name: "Belt Interface",
      trace_multiplier: 1.0,
      reward: [{:scrip, 14}],
      subroutines: [
        %{id: "belt_face_core", key: :spoof, threat: :barrier, progress_required: 11}
      ]
    },
    %{
      id: "pace_relay",
      name: "The Pace Relay",
      trace_multiplier: 1.8,
      # The reveal: the quota-orders don't originate with the Authority — they pass through it from
      # a sealed channel above. Drops the ICE-locked investigation rumor the case requires.
      reward: [
        {:rumor, "winnow_directive"},
        {:scrip, 22}
      ],
      subroutines: [
        %{id: "pace_a", key: :decrypt, threat: :sentry, progress_required: 13},
        %{id: "pace_b", key: :backdoor, threat: :sentry, progress_required: 13}
      ]
    }
  ]
}
