%{
  id: "lineman_graft",
  name: "Lineman's Graft",

  # Crude Underbelly survival-chrome: insulated dermal weave + motor-assist in the hands, so you can
  # grip a live bus and seat a relay hot. The v1 first implant — "useful before cool" (Constitution
  # Rule 4): its whole point is opening the live-bus repair path at the Power Relay.
  chrome_load: 15,
  heat_on_install: 2,
  grants: ["lineman_graft"],
  # Both inputs are salvage-recovered chrome_raws — nothing routes through Street Alchemy forage.
  # The chrome side (a servo, Scrap Yard) and the meat side (a nerve sheath, Burned Platform).
  fabrication: %{
    schematic: "schematic_lineman_graft",
    inputs: %{"salvaged_servo" => 1, "nerve_sheath" => 1}
  },

  flavor:
    "Insulated weave laid into the palms and a scavenged servo for grip. Underbelly work — crude, honest, and it means you can hold live current without it holding you.",
  install_text:
    "The graft goes in crude but seats clean. Your hands feel like someone else's — steadier."
}
