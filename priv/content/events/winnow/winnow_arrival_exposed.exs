%Shunt.Events.Event{
  id: "winnow_arrival_exposed",
  title: "Through the Door You Shut",
  repeatable: false,
  requirements: [
    {:knows, "bloom_throat_starved"}
  ],
  on_complete: [
    {:knowledge, "winnow_arrived"}
  ],
  steps: [
    %{
      id: "climb",
      text: """
      You broke the Bloom's throat and then you climbed it — up the jammed flue you
      choked off, past the harvest you stopped mid-breath, into the Spire through the
      one door nobody was supposed to be able to open from below. You come up into a
      cold shed of a room where a belt is running and grey-coveralled people are sorting
      arrivals that aren't coming anymore, because you cut the supply. They read you fast
      and they read you scared: you're not spoiled goods and you're not a warden, you're
      the thing that shut off the feed, standing on the floor that eats what the feed
      brings up. The number's going to come up short now. You already know who pays when
      it does.
      """,
      choices: [
        %{label: "Step onto the floor", complete: true}
      ]
    }
  ]
}
