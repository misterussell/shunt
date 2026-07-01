%Shunt.Events.Event{
  id: "winnow_nils_intro",
  title: "The Man Who Posts the Number",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_nils"},
    {:rumor, "winnow_wardens_afraid"}
  ],
  steps: [
    %{
      id: "booth",
      text: """
      The warden in the booth doesn't look like a man with power. He looks like a man
      doing sums he hates. "I post it, I don't set it," Nils says, before you've asked,
      nodding at the number on the glass. "It comes down. I write it up. The count comes
      up short, and then it's not my problem what closes the gap, except it is, because
      I'm the one who logs who's on the belt that day." He rubs his face. "You want to
      know why the wardens run scared in the place we're supposedly running? Stand on the
      Gantry and watch which way none of us will turn. There's a door up there. The number
      comes out of it. Nobody who wears this coat holds the key." He catches himself,
      says less. "Forget I said it. Everybody does."
      """,
      choices: [
        %{label: "Don't forget it", complete: true}
      ]
    }
  ]
}
