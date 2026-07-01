%Shunt.Events.Event{
  id: "shunt9_burned_platform_strip_sheath",
  title: "Pick the Scorch",
  repeatable: true,

  # The "meat" half of the graft, mirroring the servo salvage at the Scrap Yard. Appears once Mira
  # has taught you what to look for. The only source of nerve_sheath (a chrome_raw, salvage-only).
  requirements: [
    {:knows, "schematic_lineman_graft"}
  ],

  on_complete: [
    {:inventory, "nerve_sheath", 1},
    {:heat, 2}
  ],

  steps: [
    %{
      id: "peel",
      text: """
      Under a fallen girder, something the fire caught halfway — chrome and meat fused into
      one black knot. You crouch and work at it with the scalpel the way Mira showed you,
      finding the seam where the sheath runs. It peels off the dead nerve in one long,
      supple length, still good. You try not to think about whose arm it was. The heaps don't
      care, and neither can you.
      """,
      choices: [
        %{label: "Take the sheath", complete: true},
        %{label: "Leave it — not tonight"}
      ]
    }
  ]
}
