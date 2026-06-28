%Shunt.Events.Event{
  id: "grayline_sana_intro",
  title: "The One Who Writes",
  repeatable: false,

  on_complete: [
    {:rumor, "registry_launderer"}
  ],

  steps: [
    %{
      id: "watch",
      text: """
      At the next terminal over, a younger woman works without looking up — Sana,
      the one whose hands actually do it. She doesn't forge papers. She reaches
      into the Midgrid registry itself and adds people, edits histories, closes
      the gaps the readers would otherwise fall into. "You're staring," she says.
      "Everybody stares the first time. It's just records."
      """,
      choices: [
        %{label: "How does it not get caught?", next: "how"}
      ]
    },
    %{
      id: "how",
      text: """
      "Because I don't write lies, I launder truth." She taps the screen. "Real
      access, real records, real timestamps — borrowed off a real clerk uptown
      who thinks he's only ever helped himself. The registry can't tell my edits
      from its own. Neither can you, once Quire's done with you." She finally
      glances up. "Whatever you're about to try around me — don't. I'm the part
      of this that the Court can't replace."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    }
  ]
}
