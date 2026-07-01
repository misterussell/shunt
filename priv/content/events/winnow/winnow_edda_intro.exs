%Shunt.Events.Event{
  id: "winnow_edda_intro",
  title: "Still Useful",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "winnow_edda"},
    {:rumor, "winnow_kept_whole"}
  ],
  steps: [
    %{
      id: "belt",
      text: """
      Edda doesn't stop working the belt while she sizes you up — left, right, Cull,
      Keep, a lifetime of it in her hands. "You'll sort or you'll ride," she says. "Those
      are the jobs." She flicks an arrival left without looking. "Everybody on this floor
      came up the same throat as the load. Difference is somebody decided we were worth
      keeping at the belt instead of on it. Useful." She says the word like a handhold.
      "You stay useful, you stay off the belt. That's the whole of it up here." A pause,
      the smallest one. "Long as the number holds."
      """,
      choices: [
        %{label: "Take a place at the belt", complete: true}
      ]
    }
  ]
}
