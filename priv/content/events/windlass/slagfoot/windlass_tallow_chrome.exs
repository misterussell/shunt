%Shunt.Events.Event{
  id: "windlass_tallow_chrome",
  title: "Skin for the Heat",
  repeatable: false,

  on_complete: [
    {:scrip, -60},
    {:knowledge, "windlass_chrome_installed"},
    {:heat, 4}
  ],

  steps: [
    %{
      id: "pit",
      text: """
      Tallow works out of a casting pit gone cold, her kit laid out on a slab that
      used to hold molten iron. "You want the engine room," she says, before you've
      said anything. "Everyone who wants the engine room comes to me first, because
      everyone who goes in without me comes out cooked." She holds up a sliver of
      subdermal mesh. "Heat-sink weave, under the skin. Sixty scrip. It's not
      pretty and it's not optional."
      """,
      choices: [
        %{label: "Do it", next: "fit"},
        %{label: "Not now"}
      ]
    },
    %{
      id: "fit",
      text: """
      She works fast and without ceremony, threading the mesh along your forearms
      and up under your collar. It itches like a burn healing wrong. "There. You'll
      sweat like the rest of us but you won't drop." She wipes her hands. "The
      Fleshless don't do this out of charity — remember that when someone up the
      coil tells you what we are. Down here we just keep the crews alive. Go wake
      the engine. And try not to make a liar of me by dying anyway."
      """,
      choices: [
        %{label: "You can stand the heat now", complete: true}
      ]
    }
  ]
}
