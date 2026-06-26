%Shunt.World.NPC{
  id: "shunt9_bazaar_juno",
  name: "Juno",
  location_id: "shunt9_bazaar",

  story_arcs: [
    "shunt9_bazaar_juno_move_package",
    "shunt9_bazaar_juno_quiet_pickup"
  ],

  conditional_events: [
    "shunt9_bazaar_juno_move_package_report",
    "shunt9_bazaar_juno_quiet_pickup_report",
    "shunt9_bazaar_juno_supplier_investigation_report"
  ],

  repeatable_events: [
    "shunt9_bazaar_juno_odd_job"
  ]
}
