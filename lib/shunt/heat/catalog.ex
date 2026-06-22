defmodule Shunt.Heat.Catalog do
  @moduledoc false

  @events [
    %{
      key: "rival_undercuts_prices",
      band: :low,
      name: "Rival Undercuts Prices",
      flavor_text:
        "Word's out you're moving product. A rival fence floods your buyers' ears with a better rate.",
      scrip_loss: 10,
      cred_loss: 0
    },
    %{
      key: "tunnel_toll_hike",
      band: :low,
      name: "Tunnel Toll Hike",
      flavor_text:
        "The Syndicate's local enforcer decides Shunt 9 owes a little extra this week.",
      scrip_loss: 15,
      cred_loss: 0
    },
    %{
      key: "nervous_contact",
      band: :low,
      name: "Nervous Contact",
      flavor_text:
        "A regular buyer gets spooked by KA patrols and lowballs you just to be rid of the goods.",
      scrip_loss: 5,
      cred_loss: 1
    },
    %{
      key: "ka_stash_raid",
      band: :medium,
      name: "KA Raids a Stash",
      flavor_text:
        "Kaspav Authority sweeps a storage nook you'd been using. Cleanup and bribes eat into your cut.",
      scrip_loss: 25,
      cred_loss: 2
    },
    %{
      key: "syndicate_renegotiates",
      band: :medium,
      name: "Syndicate Renegotiates",
      flavor_text:
        "The Syndicate of Closed Hands decides your tax rate needs revisiting, effective immediately.",
      scrip_loss: 20,
      cred_loss: 4
    },
    %{
      key: "informant_chatter",
      band: :medium,
      name: "Informant Chatter",
      flavor_text:
        "Someone's been talking to Authority informants about your operation. Favors get spent quieting it.",
      scrip_loss: 15,
      cred_loss: 5
    },
    %{
      key: "corp_crackdown",
      band: :high,
      name: "Corp Crackdown",
      flavor_text:
        "Meridian Corp security leans on the Underbelly hard, and your name comes up more than once.",
      scrip_loss: 45,
      cred_loss: 6
    },
    %{
      key: "ka_task_force",
      band: :high,
      name: "KA Task Force",
      flavor_text:
        "A dedicated Kaspav Authority task force starts watching Shunt 9, and buying them off isn't cheap.",
      scrip_loss: 50,
      cred_loss: 8
    },
    %{
      key: "syndicate_makes_an_example",
      band: :high,
      name: "Syndicate Makes an Example",
      flavor_text:
        "The Syndicate decides someone needs to be made an example of, and you're too visible to skip.",
      scrip_loss: 40,
      cred_loss: 10
    }
  ]

  def events_for_band(band), do: Enum.filter(@events, &(&1.band == band))

  def fetch!(key) do
    Enum.find(@events, &(&1.key == key)) ||
      raise "unknown heat event key: #{inspect(key)}"
  end
end
