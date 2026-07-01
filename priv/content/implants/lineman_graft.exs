%{
  id: "lineman_graft",
  name: "Lineman's Graft",

  # TODO: [Chrome & Meat v1 — Milestone 4] Finalize the first implant. This is a valid stub so the
  # :implants table (once registered in Shunt.Content.Store @sources) loads without error. Fill in:
  #   - chrome_load:      integer added to Chrome Load on install (e.g. 15).
  #   - heat_on_install:  small Authority-Heat bump for crude unsanctioned graft (e.g. 2).
  #   - grants:           ["lineman_graft"] — capability key for {:has_implant, "lineman_graft"},
  #                       used by the additive live-bus solution on shunt9_power_relay_generator.
  #   - fabrication:      %{schematic: "schematic_lineman_graft", inputs: %{...chrome raws...}}.
  #                       ChromeMeat.fabricate/2 reads this; schematic taught by the Shunt 9 fitter.
  #   - install_text / flavor: crude Underbelly survival-chrome voice (Style Guide + Constitution).
  # Keep it "useful before cool" (Constitution Rule 4): the whole point is it opens the live-bus
  # repair path at the Power Relay.
  chrome_load: 0,
  heat_on_install: 0,
  grants: ["lineman_graft"]
}
