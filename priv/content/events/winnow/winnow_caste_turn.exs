%Shunt.Events.Event{
  id: "winnow_caste_turn",
  title: "Edda Reads Her Own Jaw",
  repeatable: false,
  requirements: [
    {:contact_known, "winnow_edda"},
    {:knows, "winnow_caste_stirring"},
    {:knows, "winnow_tier_above"}
  ],
  on_complete: [
    {:knowledge, "winnow_caste_lucid"}
  ],
  steps: [
    %{
      id: "turn",
      text: """
      You tell Edda what the case says — that kept-whole was never a reward, that the belt
      is just a slower Cull Line, that the number comes from a thing above the Authority
      that will get to all of them eventually, useful or not. She works the belt through the
      whole of it, left, right, Cull, Keep, and doesn't argue, because she's known longer
      than any of them. "I read my own jaw years ago," she says at last, and her hands
      finally stop. "Told myself useful meant safe. It just means later." She looks down her
      line — the caste watching her, the way a floor watches its foreman — and makes the
      first choice up here that was ever hers. "All right. If we're all going up that throat
      regardless, we go up it awake, and we take as many off the belt as we can on the way."
      The Winnow doesn't rise up. It does something quieter and more dangerous. It stops
      pretending.
      """,
      choices: [
        %{label: "Stand with them", complete: true}
      ]
    }
  ]
}
