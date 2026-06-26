alias Shunt.World.Exit

%{
  id: "shunt9_bazaar",
  name: "Shunt 9 Bazaar",

  short_description:
    "The beating heart of Shunt 9.",

  description:
    "Hundreds of stalls crowd the abandoned transit platform, lit by salvaged work lamps and the glow of a dozen black-market terminals.",

  tags: [
    :market,
    :underbelly
  ],

  graph_position: {250, 400},

  npcs: [
    "shunt9_bazaar_juno"
  ],

  events: [
    # TODO: remove "shunt9_bazaar_juno_supplier_investigation" from here — it moves to the
    # shunt9_supplier_drop location (it becomes the field-investigation leg).
    "shunt9_bazaar_juno_supplier_investigation"
    # TODO: add the report (return-beat) POIs, each gated by the return token it consumes.
    # Create each event file under priv/content/events/shunt9/bazaar/juno/:
    #   - shunt9_bazaar_juno_move_package_report  requirements [{:has_item,"juno_delivery_receipt"}];
    #       on_complete {:inventory,"juno_delivery_receipt",-1}, {:scrip,50},
    #       {:modify_rep,"juno",:trust,10}
    #   - shunt9_bazaar_juno_quiet_pickup_report  requirements [{:has_item,"juno_pickup_goods"}];
    #       on_complete {:inventory,"juno_pickup_goods",-1}, {:modify_rep,"juno",:trust,10},
    #       {:modify_rep,"juno",:favors,1}, {:knowledge,"juno_secret_supplier"}
    #   - shunt9_bazaar_juno_supplier_investigation_report requirements [{:has_item,"juno_supplier_dossier"}];
    #       on_complete {:inventory,"juno_supplier_dossier",-1}, {:scrip,150},
    #       {:modify_rep,"juno",:trust,10}
  ],

  exits: [
    %Exit{
      id: "bazaar_to_scrap_yard",
      to: "shunt9_scrap_yard"
    },
    %Exit{
      id: "bazaar_to_supplier_drop",
      to: "shunt9_supplier_drop"
    },
    %Exit{
      id: "bazaar_to_cargo_chute",
      to: "shunt9_cargo_chute",
      requirements: [
        {:rep_at_least, "juno", :trust, 20}
      ]
    },
    %Exit{
      id: "bazaar_to_food_stalls",
      to: "shunt9_food_stalls"
    },
    %Exit{
      id: "bazaar_to_power_relay",
      to: "shunt9_power_relay",
      requirements: [
        {:knows, "power_relay_entrance"}
      ]
    },
    %Exit{
      id: "bazaar_to_rooks_desk",
      to: "shunt9_rooks_desk"
    },
    %Exit{
      id: "bazaar_to_burned_platform",
      to: "shunt9_burned_platform"
    }
  ]
}
