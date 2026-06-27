%Shunt.Events.Event{
  id: "liftworks_cold_stair_off_hours",
  title: "Off Hours",

  requirements: [
    {:knows, "liftworks_back_route"}
  ],

  on_complete: [
    {:rumor, "off_hours_passage"}
  ],

  steps: [
    %{
      id: "notice",
      text: """
      You've learned the stair well enough to see what's unusual. The wear
      on the rail has a pattern that isn't just the Cold Stair's regular
      traffic — more hands than runners, more frequency than service workers.
      Marks at shoulder height where someone steadied themselves, coming down
      quietly, no torch. This route is being used at hours you haven't been
      here for.
      """,
      choices: [
        %{label: "Someone else knows this stair", complete: true},
        %{label: "Could be anyone"}
      ]
    }
  ]
}
