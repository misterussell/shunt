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
      match?({:ok, _}, fabricate(player, def.id)) -> :fabricable
      true -> :locked
    end
  end

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

  # TODO: [Chrome & Meat v1 — Milestone 4] Shunt 9 content to author (each its own file):
  #   1. priv/content/implants/lineman_graft.exs — the first implant (stub already staged).
  #   2. A new back-alley grafter world_npc under priv/content/world_npcs/shunt9/ (Maintenance Tunnel
  #      OR Burned Platform — both one hop from spawn). Surfaced only when Shunt 9 `power >= :partial`,
  #      mirroring how Volt appears at power :online (copy shunt9_bazaar_volt's gating mechanism).
  #      Offers: teach the lineman_graft schematic (grant {:knowledge, "schematic_lineman_graft"}),
  #      and perform the install. Seed the Fleshless supply thread (subdermal wiring) for v2.
  #   3. The fitter's intro + install events under priv/content/events/shunt9/... referenced by the
  #      NPC's story_arcs (keep NPC↔event ids consistent so World.Npcs.current_event/2 resolves).
  #   4. A salvage/"recover" event that grants the chrome raws (e.g. salvaged_servo) — the ONLY source
  #      of chrome raws; do NOT add them to priv/content/raws consumed by global scavenge.
  #   5. The Chrome Load foreshadowing event: gated {:chrome_load_at_least, <low threshold>}, mild and
  #      ominous (the seam itches; a reader's eye lingers). No harvest reveal.
  #   6. Register new recurring terms in docs/SHUNT_LEXICON.md (the fitter, "Chrome Load", the graft,
  #      chrome raw names) per Content Constitution Rule 5.
end
