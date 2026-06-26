alias Shunt.World.Exit

%{
  id: "shunt9_food_stalls",
  name: "Food Stalls",

  short_description:
    "Grease smoke and shouted orders fill the narrow row.",

  description:
    "Vendors work woks and grills shoulder to shoulder, serving whatever the yard and the relay traps have turned up that day.",

  tags: [
    :market,
    :social
  ],

  graph_position: {250, 570},

  # TODO: create the recipient world-NPC for Juno's errands (her recurring go-between/fence;
  # new file under priv/content/world_npcs/shunt9/food_stalls/, name per SHUNT_NAMING_PATTERNS,
  # arc/repeatable shaped like shunt9_bazaar_juno.exs) and list it here as
  # npcs: ["<recipient_npc_id>"]. This one contact receives both errands' outbound items.
  # TODO: add an events: [...] list with the leg-1 (handoff) POIs, each gated by the carried
  # item it consumes. Create each event file under priv/content/events/shunt9/bazaar/juno/:
  #   - shunt9_bazaar_juno_deliver_parcel  requirements [{:has_item,"juno_parcel"}];
  #       on_complete {:inventory,"juno_parcel",-1}, {:inventory,"juno_delivery_receipt",1}
  #   - shunt9_bazaar_juno_collect_pickup  requirements [{:has_item,"juno_pickup_chit"}];
  #       on_complete {:inventory,"juno_pickup_chit",-1}, {:inventory,"juno_pickup_goods",1}
  exits: [
    %Exit{
      id: "food_stalls_to_bazaar",
      to: "shunt9_bazaar"
    }
  ]
}
