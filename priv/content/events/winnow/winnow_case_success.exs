%Shunt.Events.Event{
  id: "winnow_case_success",
  title: "Above the Hand",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:knowledge, "winnow_tier_above"}
  ],
  steps: [
    %{
      id: "shape",
      text: """
      Laid side by side, the pieces stop being grievances and start being a diagram. The
      quota that comes down a channel no warden holds. The spoiled count climbing while
      something upstream turns choosier. The kept-whole caste, spared not as mercy but as
      maintenance staff. Tithe, half-taken and still knowing. The door on the Gantry that
      even Halden can't face. It all points past the Authority — past the wardens, past
      the readers and the ICE and the whole apparatus you fought your way up through. The
      Authority isn't at the top. The Authority is a hand. Something above it writes the
      number, eats what the Winnow sends up, and decides how choosy the wire gets to be —
      and it has never once been seen by anyone who came from below. Until, maybe, you. The
      sealed door will open for someone who knows this much. It shouldn't. That's the point.
      """,
      choices: [
        %{label: "Go to the door", complete: true}
      ]
    }
  ]
}
