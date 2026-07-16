# TODO (Splice fold-in): this existing world NPC absorbs the retired `splice` Hub contact.
#   - Add `contact_key: "splice"` (preserves the existing loyalty key; struct id stays prefixed).
#   - Add a `services:` list (see lib/shunt/contacts.ex for the shape):
#       basic  :data_drop, requirements [{:knows, "splice_intro"}],
#              params %{cost: 20, gain_cred: 1}   (the retired trade_action, verbatim numbers)
#       mid    :data_drop, requirements [{:knows, "splice_task1"}], params %{cost: 15, gain_cred: 2}
#       best   :data_drop, requirements [{:knows, "splice_task2"}], params %{cost: 15, gain_cred: 3}
#     (tune numbers during content pass; keep basic == today's deal.)
#   - Extend story_arcs so the arc grants the unlock flags: the existing intro-ish arc entry's
#     event on_complete grants {:knowledge, "splice_intro"}; add two task events granting
#     "splice_task1" / "splice_task2". Reuse liftworks_splice_blind_spot as the intro if it fits.
#   - Delete priv/content/npcs/splice.exs.
%Shunt.World.NPC{
  id: "liftworks_splice",
  name: "Splice",
  location_id: "liftworks_transfer_row",

  story_arcs: [
    "liftworks_splice_blind_spot"
  ]
}
