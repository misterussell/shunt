%Shunt.Events.Event{
  id: "liftworks_nine_iron_task2",
  title: "Off the Ledger",

  on_complete: [
    {:knowledge, "nine_iron_task2"},
    {:npc_progression, "liftworks_nine_iron", 1}
  ],

  steps: [
    %{
      id: "open",
      text: """
      Nine-Iron is at the records terminal in the corner when you come in, the
      one wired straight into the Latticework. He doesn't stop scrolling. "You've
      been a clean line on my books a while now. No noise, no questions, scrip on
      time." He gestures at the screen without looking. "So I did the reckless
      thing. I went looking for your echo in the Permit Registry."
      """,
      choices: [
        %{label: "And?", next: "change"},
        %{label: "That was reckless", next: "why"}
      ]
    },
    %{
      id: "change",
      text: """
      "And I unwrote it. Not softened, not misfiled — gone. The registry has no
      line for you now, so the Authority has no heat to hang on you." He finally
      turns from the terminal. "You climb, you deal, you don't exist to the
      reader. That's as far off the ledger as anyone gets and still breathes.
      Cheaper than ever, because there's less of you left to hide."
      """,
      choices: [
        %{label: "Understood", complete: true}
      ]
    },
    %{
      id: "why",
      text: """
      "Reckless is filing paper that can be read back to you. This can't." A
      rare, dry almost-smile. "The registry trusts a warden's write-head, and
      I've been that write-head twenty years. Nobody audits the man who runs the
      audit." He turns back to the screen. "You're the cleanest thing I've done
      off the books. Don't make me regret the entry I deleted."
      """,
      choices: [
        %{label: "I won't", complete: true}
      ]
    }
  ]
}
