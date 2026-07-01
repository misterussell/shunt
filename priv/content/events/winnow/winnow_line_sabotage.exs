%Shunt.Events.Event{
  id: "winnow_line_sabotage",
  title: "Jam the Line",
  repeatable: false,
  requirements: [
    {:contact_known, "winnow_roan"}
  ],
  on_complete: [
    {:knowledge, "winnow_line_jammed"},
    {:heat, 18}
  ],
  steps: [
    %{
      id: "jam",
      text: """
      "There's another way to play it," Roan says, quieter, because this one's dangerous.
      "You don't hide the shortfall. You make it enormous. Kill the drive, foul the
      readers, stop the line dead — the count craters, the number can't be made any way but
      culling, and the wardens have to choose, out in the open, in front of everybody, to
      feed their own to the wire to hit a quota that came from a door they're scared of."
      He lets that sit. "It forces the thing into the light. Some of the caste wake up when
      they see it. Some of them go on the belt for it — that's the cost, and it's real, and
      it's on you." He hands you the pry bar anyway. "Padding the count keeps people alive
      quiet. Jamming it might get people free loud. I've never been sure which is braver."
      """,
      choices: [
        %{label: "Break the drive", complete: true}
      ]
    }
  ]
}
