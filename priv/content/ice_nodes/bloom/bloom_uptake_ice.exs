%Shunt.Ghostwork.IceNode{
  id: "bloom_uptake_ice",
  name: "The Throat's Core",
  family: "ice_authority",
  location_id: "bloom_uptake",
  description:
    "The ascent gate isn't a door. It's an interface — the throat where the Bloom's chosen are handed up, and the deepest, meanest ICE the Authority keeps anywhere in the Midgrid. You reached it holding clearance, believing the worst was that they buy your name and retire you quiet. Crack the core and you find out what ascent actually does. You will not be able to unknow it.",
  requirements: [
    {:knows, "bloom_ascent_clearance"}
  ],
  cool_threshold: 90,
  layers: [
    %{
      id: "gate_face",
      name: "Gate Face",
      trace_multiplier: 1.0,
      reward: [{:scrip, 20}],
      subroutines: [
        %{id: "gate_face_core", key: :spoof, threat: :barrier, progress_required: 12}
      ]
    },
    %{
      id: "wardens",
      name: "The Warden Ring",
      trace_multiplier: 1.6,
      reward: [{:scrip, 18}],
      subroutines: [
        %{id: "warden_a", key: :decrypt, threat: :sentry, progress_required: 13},
        %{id: "warden_b", key: :backdoor, threat: :sentry, progress_required: 13}
      ]
    },
    %{
      id: "the_shunt",
      name: "The Shunt",
      trace_multiplier: 3.0,
      # The reveal: peels the echo-harvest cover off the substrate-truth. This flag gates the
      # Ascend/Expose finale fork events (authored in the events stage).
      reward: [
        {:knowledge, "bloom_truth_substrate"},
        {:scrip, 36}
      ],
      subroutines: [
        %{id: "shunt_trap", key: :spoof, threat: :trap, progress_required: 12},
        %{id: "shunt_lock", key: :backdoor, threat: :barrier, progress_required: 16}
      ]
    }
  ]
}
