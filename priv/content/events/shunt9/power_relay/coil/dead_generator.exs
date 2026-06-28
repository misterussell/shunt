# TODO: This conversation has no on_complete reward. Decide whether agreeing to help Coil
# ("I'll take a look.") should grant anything — scrip, a small loyalty bump, or a knowledge/
# rumor flag that the broken generator is now a known job — vs. staying pure flavor that only
# points the player at the Infrastructure panel. Currently it grants nothing either way.
%Shunt.Events.Event{
  id: "shunt9_power_relay_coil_dead_generator",
  title: "Coil — The Dead Generator",

  requirements: [{:infra_state, "shunt9_power_relay_generator", "broken"}],

  steps: [
    %{
      id: "complaint",
      text: """
      Coil's working the main bus, but their eyes keep drifting to the
      cold box in the corner. "Backup's been dead a month. Main relay
      drops for one second and we lose half the district." A grimace.
      "I keep the lights on. I can't be the lights on."
      """,
      choices: [
        %{label: "What's wrong with it?", next: "diagnosis"},
        %{label: "Not my problem.", complete: true}
      ]
    },
    %{
      id: "diagnosis",
      text: """
      "If I knew, it'd be fixed." They wipe their hands. "Starter
      relay, probably. They always go. I've got no spare and no time
      to make one." A look at you, weighing. "You're handy. Crack it
      open yourself if you want. I won't stop you."
      """,
      choices: [
        %{label: "I'll take a look.", complete: true}
      ]
    }
  ]
}
