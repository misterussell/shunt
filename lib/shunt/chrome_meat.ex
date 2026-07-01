defmodule Shunt.ChromeMeat do
  @moduledoc """
  Chrome & Meat (body modification) — the body-side of the harvest.

  Pure domain module: every function takes a `%Shunt.Players.Player{}` and returns an effect
  list (`{:ok, effects}` / `{:ok, effects, meta}` / `{:error, reason}`) for `Shunt.Players.dispatch/2`
  to apply. It never touches the Repo. Modeled on `Shunt.Ghostwork` (per-skill logic returning
  effect lists) and `Shunt.Heat` (capped threshold meter).

  Full design: priv/docs/SHUNT_chrome_and_meat_v1.md.
  """

  alias Shunt.Implants
  alias Shunt.Players.Player
  alias Shunt.Requirements
  alias Shunt.Skills.Catalog, as: SkillsCatalog

  @max_load 100
  @low_threshold 30
  @medium_threshold 60
  @high_threshold 85

  @doc "Pins a Chrome Load value to 0..#{@max_load}. Distinct meter from Authority Heat."
  def clamp(load), do: load |> max(0) |> min(@max_load)

  @doc "The Chrome Load band for a value, for UI styling. Threshold shape mirrors Shunt.Heat."
  def band_for(load) when load >= @high_threshold, do: :high
  def band_for(load) when load >= @medium_threshold, do: :medium
  def band_for(load) when load >= @low_threshold, do: :low
  def band_for(_load), do: :none

  @doc """
  Decorates every implant def with the player's relationship to it, so the LiveView renders state
  without recomputing domain rules. State is one of :installed, :owned (built, uninstalled),
  :fabricable (can build now), or :locked (missing tool/schematic/materials). Sorted by name.

  Note: unlike Shunt.Heat, Chrome Load does NOT fire events mid-effect. The Shunt 9 v1 foreshadowing
  beat is a narrative conditional event gated on {:chrome_load_at_least, n} — more idiomatic than a
  Heat-style resolve.
  """
  def catalog(%Player{} = player) do
    Implants.items()
    |> Enum.sort_by(& &1.name)
    |> Enum.map(fn def -> %{def: def, state: state_for(player, def)} end)
  end

  defp state_for(player, def) do
    cond do
      Map.has_key?(player.implants, def.id) -> :installed
      Map.get(player.inventory, def.id, 0) >= 1 -> :owned
      true -> fabrication_state(fabricate(player, def.id))
    end
  end

  # :fabricable when it can be built now; :needs_materials when only the inputs are missing (tool +
  # schematic held) so the UI can point the player at salvage; :locked when the tool or schematic is
  # missing (or the implant is NPC-only).
  defp fabrication_state({:ok, _}), do: :fabricable
  defp fabrication_state({:error, :insufficient_materials}), do: :needs_materials
  defp fabrication_state({:error, _}), do: :locked

  @doc """
  Fabricate an (uninstalled) implant from its `fabrication` block. Self-contained under Chrome &
  Meat: gated on the chrome tool (tier 1) + the learned schematic + the input materials — NOT on
  street_alchemy tier. Returns {:ok, effects} that consume the inputs and grant the implant item.
  """
  def fabricate(%Player{} = player, implant_key) do
    def = Implants.fetch!(implant_key)

    cond do
      not Map.has_key?(def, :fabrication) ->
        {:error, :not_fabricable}

      SkillsCatalog.current_tier(player, SkillsCatalog.fetch!("chrome_meat")) < 1 ->
        {:error, :insufficient_tier}

      not Requirements.met?(player, [{:knows, def.fabrication.schematic}]) ->
        {:error, :unknown_schematic}

      not holds_inputs?(player, def.fabrication.inputs) ->
        {:error, :insufficient_materials}

      true ->
        consume = for {key, qty} <- def.fabrication.inputs, do: {:inventory, key, -qty}
        {:ok, consume ++ [{:inventory, implant_key, 1}]}
    end
  end

  @doc """
  Install an owned (uninstalled) implant. Deterministic by inputs — no RNG in v1. Consumes the
  implant item, marks it installed, and applies its Chrome Load + Authority-Heat cost.
  """
  def install(%Player{} = player, implant_key) do
    def = Implants.fetch!(implant_key)

    cond do
      Map.get(player.inventory, implant_key, 0) < 1 ->
        {:error, :not_owned}

      Map.has_key?(player.implants, implant_key) ->
        {:error, :already_installed}

      true ->
        {:ok,
         [
           {:inventory, implant_key, -1},
           {:install_implant, implant_key},
           {:chrome_load, def.chrome_load},
           {:heat, def.heat_on_install}
         ]}
    end
  end

  defp holds_inputs?(player, inputs) do
    Enum.all?(inputs, fn {key, qty} -> Map.get(player.inventory, key, 0) >= qty end)
  end
end
