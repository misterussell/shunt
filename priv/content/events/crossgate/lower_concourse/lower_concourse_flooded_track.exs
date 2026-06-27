%Shunt.Events.Event{
  id: "crossgate_lower_concourse_flooded_track",
  title: "Flooded Track",

  steps: [
    %{
      id: "inspect",
      text: """
      At the far end of the lower concourse, the original track bed
      disappears under a metre of black water. The flooding is old —
      the waterline stains on the walls show it's been here for years,
      rising slightly, never receding. Things float in it that you
      don't look at closely.
      """,
      choices: [
        %{label: "Look closer", next: "look"},
        %{label: "Keep your distance"}
      ]
    },
    %{
      id: "look",
      text: """
      Old equipment — a maintenance cart, bundled cable, what might
      have been personal effects at one point. The track runs into
      a sealed tunnel mouth under the waterline. Whatever's in there
      has been sealed since before the flooding started. Nobody's
      going in that way, and whatever's in there isn't coming out.
      """,
      choices: [
        %{label: "Leave it."}
      ]
    }
  ]
}
