%Shunt.Events.Event{
  id: "shunt9_power_relay_backup_online",
  title: "Charging Bench",

  requirements: [{:infra_state, "shunt9_power_relay_generator", "repaired"}],

  on_complete: [{:scrip, 6}, {:npc_loyalty, "shunt9_power_relay_coil", 1}],

  steps: [
    %{
      id: "bench",
      text: """
      With the backup carrying the slack, the maintenance bench along
      the wall has power again. A row of outlets, a battery rack, a
      slow trickle of credit fragments draining off an old metering
      circuit nobody ever shut down.
      """,
      choices: [
        %{label: "Pull the loose fragments.", next: "skim"},
        %{label: "Leave it." }
      ]
    },
    %{
      id: "skim",
      text: """
      You bleed the metering circuit dry — a handful of fragments, the
      kind of thing only worth grabbing because the power's back to
      grab them with. Coil pretends not to notice.
      """,
      choices: [
        %{label: "Pocket it.", complete: true}
      ]
    }
  ]
}
