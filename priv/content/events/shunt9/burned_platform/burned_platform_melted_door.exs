%Shunt.Events.Event{
  id: "shunt9_burned_platform_melted_door",
  title: "Melted Door",

  steps: [
    %{
      id: "inspect",
      text: """
      Melted metal and scorched concrete mark the remains of a bulwark door. It has been centuries since it was last used. The door is fused to the frame, and there is no way to open it.
      """,
      choices: [
        %{label: "Examine door", next: "door"},
        %{label: "Leave it alone"}
      ]
    },
    %{
      id: "door",
      text: """
      You can still see the outline of the mechanism that once controlled it. It will take a skilled engineer to repair it, and even then, it may never work again.

      The local children fear the door, deep grooves like claws on metal mark a strange symbol with a lost meaning.
      """,
      choices: [
        %{label: "Leave it alone"},
      ]
    }
  ]
}
