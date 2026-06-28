%Shunt.Events.Event{
  id: "shunt9_burned_platform_ash_intro",
  title: "Picking the Dark",

  on_complete: [
    {:npc_progression, "shunt9_burned_platform_ash", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      A thin figure crouches in the soot, sorting char with blackened fingers —
      melted fixtures, a cracked cell, anything the fire left worth lifting. He
      flinches at your step, then settles when he sees you're no one who matters.
      "Ash," he says, before you ask. "Nobody works the dark end unless they're
      working it too. Plenty down here, long as the lights stay off."
      """,
      choices: [
        %{label: "Why only in the dark?", next: "dark"},
        %{label: "Good pickings?", next: "pickings"}
      ]
    },
    %{
      id: "dark",
      text: """
      "Light brings people. People bring owners." He pockets a twist of copper.
      "Right now this stretch belongs to whoever's brave enough to breathe the
      soot. Grid comes all the way back, somebody'll remember they own it — and
      I'll be gone before they do." He says it flat, like weather.
      """,
      choices: [
        %{label: "Fair enough", complete: true}
      ]
    },
    %{
      id: "pickings",
      text: """
      "Good enough for now." He turns the cracked cell over in the gloom. "Fire
      cooks the cheap stuff and leaves the good stuff sulking under it. You just
      have to want it more than you mind the dark." He goes back to sorting.
      "Most don't. That's the pickings."
      """,
      choices: [
        %{label: "Leave him to it", complete: true}
      ]
    }
  ]
}
