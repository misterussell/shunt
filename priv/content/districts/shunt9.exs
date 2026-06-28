%Shunt.District.Def{
  id: "shunt9",
  name: "Shunt 9",
  facts: %{
    # Power is derived entirely from the backup generator repair in the Power Relay. A patched
    # generator runs rough (partial); a fully repaired one holds steady (online). Nothing about
    # power is stored separately — it falls out of player.infrastructure.
    power: %{
      kind: :ordinal,
      levels: [:offline, :partial, :online],
      default: :offline,
      rules: [
        {:online, [{:infra_state, "shunt9_power_relay_generator", "repaired"}]},
        {:partial, [{:infra_state, "shunt9_power_relay_generator", "patched"}]}
      ]
    }
  }
}
