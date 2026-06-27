%Shunt.Events.Event{
  id: "liftworks_proxy_quiet_word",
  title: "A Quiet Word",

  on_complete: [
    {:contact, "liftworks_proxy"},
    {:npc_progression, "liftworks_proxy", 1},
    {:rumor, "proxy_pipeline"}
  ],

  steps: [
    %{
      id: "bench",
      text: """
      A woman on the end bench has the look of someone who isn't waiting for
      anything — she's working. She clocks you clocking her. "You're not held,"
      she says. "You're shopping. Sit down before the guard wonders." She doesn't
      offer a name. People call her Proxy because she stands in for whoever you
      need to be.
      """,
      choices: [
        %{label: "What do you sell?", next: "offer"},
        %{label: "I'm fine, thanks"}
      ]
    },
    %{
      id: "offer",
      text: """
      "Two things, mostly. Paper that says you're cleared when you're not. And a
      way up that skips the reader entirely, for people the paper won't cover."
      She lets that sit. "Either one, you come to me. Stamp's fair and slow. I'm
      neither. Remember which you'd rather have."
      """,
      choices: [
        %{label: "I'll remember you", complete: true}
      ]
    }
  ]
}
