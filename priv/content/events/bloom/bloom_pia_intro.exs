%Shunt.Events.Event{
  id: "bloom_pia_intro",
  title: "The Count",
  repeatable: false,
  requirements: [],
  on_complete: [
    {:contact, "bloom_pia"},
    {:rumor, "bloom_finished_crop"}
  ],
  steps: [
    %{
      id: "galley",
      text: """
      Pia doesn't stop working while she talks — hands moving, eyes down, the way
      someone talks when they've learned nobody watches them do it. "You get to
      know the ones going up," she says. "They come through here first. Last
      fitting, we call it. Fed right up, groomed, sent off shining." She plates
      another and slides it away. "I started counting them. Thought it'd go both
      ways, people coming and going. It doesn't. They only ever go."
      """,
      choices: [
        %{label: "Ask how high the count is", complete: true}
      ]
    }
  ]
}
