%Shunt.Events.Event{
  id: "shunt9_scrap_yard_strip_servo",
  title: "Strip a Servo-Rig",
  repeatable: true,

  # Appears once the fitter has taught you the graft — now the heaps read as parts, not junk. This is
  # the only source of salvaged_servo (a chrome_raw, kept out of the global scavenge pool).
  requirements: [
    {:knows, "schematic_lineman_graft"}
  ],

  on_complete: [
    {:inventory, "salvaged_servo", 1},
    {:heat, 2}
  ],

  steps: [
    %{
      id: "cut",
      text: """
      A wrecked loader lies half-buried in the heap, one arm still folded like it's
      cradling something. You cut the housing and work the motor-assist free — greased,
      intact, better than anything the fitter's got on his bench. Someone's magnet rig
      whines two rows over; you pocket the servo and don't look up.
      """,
      choices: [
        %{label: "Pull the servo", complete: true},
        %{label: "Leave it — too many eyes"}
      ]
    }
  ]
}
