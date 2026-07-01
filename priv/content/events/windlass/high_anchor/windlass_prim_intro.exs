%Shunt.Events.Event{
  id: "windlass_prim_intro",
  title: "The List She Drafted",
  repeatable: false,

  on_complete: [
    {:rumor, "windlass_permit_purge"}
  ],

  steps: [
    %{
      id: "walk",
      text: """
      Prim keeps you walking while she talks, two permitted residents taking the
      clean air, nothing to see. "Marrow sent you. He shouldn't have, and I'm glad
      he did." Her voice stays pleasant, for the walls. "I do clerical work for the
      Ascent Office. Three months ago they had me help compile a list. Every hollow
      in the Windlass, sorted by turn. I thought it was a census."
      """,
      choices: [
        %{label: "It wasn't a census.", next: "list"}
      ]
    },
    %{
      id: "list",
      text: """
      "It was a purge list. A schedule. Names queued to be cleared out ahead of
      certification — dated to the same week the freight stopped." She smiles at a
      passing neighbour, waits, goes on. "I signed my name to part of it before I
      understood. That's the thing about order up here: it makes you complicit
      before it lets you see. I can't undo it. But I can tell you it exists, and
      that it started before the engine ever failed. Whoever stopped the freight
      wanted the count clean. Now go prove it, before my name's the one signing the
      next one."
      """,
      choices: [
        %{label: "It won't come to that", complete: true}
      ]
    }
  ]
}
