%Shunt.Events.Event{
  id: "windlass_sabotage_success",
  title: "The Stall Was Sabotage",
  repeatable: false,

  on_complete: [
    {:knowledge, "windlass_case_cracked"},
    {:scrip, 40},
    {:cred, 5},
    {:npc_loyalty, "windlass_drift", 4}
  ],

  steps: [
    %{
      id: "whole",
      text: """
      The threads pull tight and the whole lie stands clear. The governor pulled by
      an authorized hand. The failure report written and sealed three days before
      the inspector looked. The purge list dated to the week the freight stopped.
      And under all of it, recovered from the permit registry itself, the standing
      order — hold the freight, clear the count — signed off High Anchor before the
      engine ever failed. They didn't cover up a breakdown. They manufactured one,
      to have a reason to lock the grid and empty the district before the Spire came
      counting.
      """,
      choices: [
        %{label: "So what happens now?", next: "open"}
      ]
    },
    %{
      id: "open",
      text: """
      Now it can't be un-known. Drift has the order copied a dozen ways before you've
      finished explaining it; Sable already knows what it's worth; Marrow, for the
      first time since you met him, looks like a man who might not be cleared out
      after all. The way up is yours whenever you want it — but the Windlass will be
      a different place depending on how you leave it. Wake the engine, throw the
      grid open, take the quiet permit, or burn the order across every reader in the
      district. The truth is the lever. You decide where to put it.
      """,
      choices: [
        %{label: "Head for the Anchor Gate", complete: true}
      ]
    }
  ]
}
