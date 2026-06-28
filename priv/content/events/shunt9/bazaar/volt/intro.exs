%Shunt.Events.Event{
  id: "shunt9_bazaar_volt_intro",
  title: "The New Bench",

  on_complete: [
    {:npc_progression, "shunt9_bazaar_volt", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      A bench that wasn't here last week: trays of pulled boards, reels of salvaged
      wire, a soldering iron ticking as it warms. The man behind it doesn't look up
      from the relay he's reseating. "Lights came back on. Figured it was worth
      hauling the kit down." He sets the board aside. "Volt. I fix what the dark
      broke — but only if there's a clean line to test it on. There is now."
      """,
      choices: [
        %{label: "What do you run?", next: "run"},
        %{label: "You read the grid fast", next: "grid"}
      ]
    },
    %{
      id: "run",
      text: """
      "Anything that needs juice. Charge cells, board repairs, the odd bit of kit
      nobody else down here can power up long enough to know if it's dead." He taps
      the live bench, worklight steady above it. "Couldn't do a lick of this on a
      dead grid. Come back when you've got something that needs power through it."
      """,
      choices: [
        %{label: "I'll do that", complete: true}
      ]
    },
    %{
      id: "grid",
      text: """
      "I bet my stock on it." He nods at the worklight — not flickering, not dying,
      just on. "That light holds, traders follow it down. I'm the first one stupid
      enough to set up before the rest catch on." A short grin. "Don't make me
      regret being early."
      """,
      choices: [
        %{label: "Wouldn't dream of it", complete: true}
      ]
    }
  ]
}
