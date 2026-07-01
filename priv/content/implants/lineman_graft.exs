%{
  id: "lineman_graft",
  name: "Lineman's Graft",

  # Crude Underbelly survival-chrome: insulated dermal weave + motor-assist in the hands, so you can
  # grip a live bus and seat a relay hot. The v1 first implant — "useful before cool" (Constitution
  # Rule 4): its whole point is opening the live-bus repair path at the Power Relay.
  chrome_load: 15,
  heat_on_install: 2,
  grants: ["lineman_graft"],
  fabrication: %{
    schematic: "schematic_lineman_graft",
    inputs: %{"salvaged_servo" => 1, "subdermal_wiring_bundle" => 1}
  },

  # TODO: [Chrome & Meat v1 — Milestone 4] Add install_text / flavor prose (crude survival-chrome
  # voice, Style Guide + Constitution). Author the surrounding Shunt 9 content that makes fabrication
  # reachable: the "salvaged_servo" chrome raw (salvage-event drop only, NOT global scavenge) and a
  # source that grants {:knowledge, "schematic_lineman_graft"} (the fitter). See the Milestone 4
  # content checklist in lib/shunt/chrome_meat.ex.
  install_text: "The graft goes in crude but seats clean. Your hands feel like someone else's — steadier."
}
