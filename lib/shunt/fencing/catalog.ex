defmodule Shunt.Fencing.Catalog do
  @moduledoc false

  # TODO: per priv/docs/architecture.md Section 4, move each map in @items below into its
  # own file under priv/content/fencing/<key>.exs (mirroring priv/npcs/*.exs), delete @items,
  # and reimplement items/0 and fetch!/1 below as delegates to
  # Shunt.Content.all(:fencing_items) and Shunt.Content.fetch!(:fencing_items, key)
  # respectively. Requires Shunt.Content.Store (lib/shunt/content/store.ex) to be implemented
  # and wired into lib/shunt/application.ex first, with :fencing_items in its @sources.

  @items [
    %{
      key: "scrap_dermal_plating",
      name: "Scrap Dermal Plating",
      tier: :clean,
      buy_cost: 10,
      sell_value: 18,
      heat_cost: 5,
      cred_gain: 1,
      offer_text: "A ganger's leftovers — dented plating still tacky with someone else's blood.",
      sell_text: "A patcher in a stall off the main concourse barely looks up before paying."
    },
    %{
      key: "bootleg_credchip_stack",
      name: "Bootleg Credchip Stack",
      tier: :clean,
      buy_cost: 15,
      sell_value: 25,
      heat_cost: 6,
      cred_gain: 1,
      offer_text: "Counterfeit chips, good enough to fool a distracted register — for a while.",
      sell_text: "A till-runner takes the stack without counting it twice."
    },
    %{
      key: "grey_market_neural_patch",
      name: "Grey-Market Neural Patch",
      tier: :warm,
      buy_cost: 25,
      sell_value: 45,
      heat_cost: 12,
      cred_gain: 2,
      offer_text: "An unlicensed reflex patch, still warm from whoever wore it last.",
      sell_text: "A Graftsman's apprentice pays cash, no questions, no receipt."
    },
    %{
      key: "cracked_latticework_relay_key",
      name: "Cracked Latticework Relay Key",
      tier: :warm,
      buy_cost: 30,
      sell_value: 55,
      heat_cost: 15,
      cred_gain: 3,
      offer_text:
        "A stolen access token. Somewhere uptown, it's still pinging for a body that isn't yours.",
      sell_text: "A Latticework Collective courier pays fast and leaves faster."
    },
    %{
      key: "stolen_corp_biomod_prototype",
      name: "Stolen Corp Biomod Prototype",
      tier: :hot,
      buy_cost: 55,
      sell_value: 110,
      heat_cost: 28,
      cred_gain: 4,
      offer_text:
        "Sealed casing, corp serials filed off. Whoever lost this is already looking for it.",
      sell_text:
        "A Chrome & Meat broker doesn't ask where it came from — just whether it's clean."
    },
    %{
      key: "burned_netrunners_memory_core",
      name: "Burned Netrunner's Memory Core",
      tier: :hot,
      buy_cost: 65,
      sell_value: 130,
      heat_cost: 32,
      cred_gain: 5,
      offer_text:
        "Salvaged off a netrunner who flatlined mid-run. Still humming with whatever fried them.",
      sell_text: "A Fleshless acolyte trades scrip for it like it's a relic."
    }
  ]

  def items, do: @items

  def fetch!(key) do
    Enum.find(@items, &(&1.key == key)) ||
      raise "unknown catalog item key: #{inspect(key)}"
  end
end
