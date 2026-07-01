%Shunt.Events.Event{
  id: "winnow_roan_intro",
  title: "The Man Who Woke Up",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_roan"},
    {:rumor, "winnow_spoiled_count"}
  ],
  steps: [
    %{
      id: "market",
      text: """
      Roan finds you before you find him — a man with the easy look of someone who
      stopped lying to himself a while ago and found it restful. "You're the spoiled one,
      or the one that broke the feed. Either way you're awake, and awake's rare up here."
      He keeps his voice under the belt-noise. "Most of the caste sleeps standing up. Tell
      themselves they made it. Easier." He shrugs. "I run the galley's market. I move what
      the benches skim, I keep a count of my own — and my count says the spoiled numbers
      are climbing. More of us the wire won't take, every season. Somebody up past the
      wardens is getting picky, and nobody's asking why." He smiles, no warmth in it.
      "You want to be useful to something other than the machine, come see me."
      """,
      choices: [
        %{label: "Remember the way back", complete: true}
      ]
    }
  ]
}
