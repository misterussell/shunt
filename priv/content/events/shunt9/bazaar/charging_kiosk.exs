%Shunt.Events.Event{
  id: "shunt9_bazaar_charging_kiosk",
  title: "The Kiosk Wakes",

  # A dead public terminal that only boots once the district grid is live. Pure content gate —
  # World.points_of_interest/2 hides it until district power reaches online.
  requirements: [
    {:district, "shunt9", :power, :>=, :online}
  ],

  on_complete: [
    {:scrip, 6}
  ],

  steps: [
    %{
      id: "boot",
      text: """
      The old fare kiosk in the corner of the market hasn't shown a pixel in years.
      Now its screen is up — pale, flickering, running through a boot sequence
      nobody asked for. Grid's back, so the kiosk's back, dragging a decade of
      cached transit traffic up with it. Half of it's garbage. Some of it isn't.
      """,
      choices: [
        %{label: "Scrape the cache before it clears", next: "scrape"},
        %{label: "Let it boot and walk away"}
      ]
    },
    %{
      id: "scrape",
      text: """
      You pull what you can before the kiosk finishes waking and flushes the lot.
      Mostly dead fare records — but folded in among them, a handful of credit
      fragments the system never reconciled, yours now for the lifting.
      """,
      choices: [
        %{label: "Pocket it", complete: true}
      ]
    }
  ]
}
