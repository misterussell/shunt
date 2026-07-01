defmodule Shunt.ChromeMeat do
  @moduledoc """
  Chrome & Meat (body modification) — the body-side of the harvest.

  Pure domain module: every function takes a `%Shunt.Players.Player{}` and returns an effect
  list (`{:ok, effects}` / `{:ok, effects, meta}` / `{:error, reason}`) for `Shunt.Players.dispatch/2`
  to apply. It never touches the Repo. Modeled on `Shunt.Ghostwork` (per-skill logic returning
  effect lists) and `Shunt.Heat` (capped threshold meter).

  Full design: priv/docs/SHUNT_chrome_and_meat_v1.md.
  """

  @max_load 100

  @doc "Pins a Chrome Load value to 0..#{@max_load}. Distinct meter from Authority Heat."
  def clamp(load), do: load |> max(0) |> min(@max_load)

  # Note: unlike Shunt.Heat, Chrome Load does NOT fire events mid-effect. The Shunt 9 v1
  # foreshadowing beat is a narrative conditional event gated on {:chrome_load_at_least, n}
  # (see Milestone 4 content TODOs), which is more idiomatic than a Heat-style resolve. A
  # band_for/1 (for UI styling) is added in Milestone 3 when the meter is rendered.

  # TODO: [Chrome & Meat v1 — Milestone 2] fabricate(player, implant_key):
  #   Reads the implant def's `fabrication` block from Shunt.Implants.fetch!/1. Returns {:error, ...}
  #   unless ALL of: player owns the chrome tool (patchwork_scalpel), player knows the schematic
  #   ({:knows, fabrication.schematic} via Shunt.Requirements.met?/2), and player holds every input in
  #   fabrication.inputs. On success returns {:ok, consume-inputs effects ++ [{:inventory, implant_key, +1}]}.
  #   The schematic-lock lives HERE, not in Shunt.Crafting.assemble — chrome fabrication is
  #   self-contained and does NOT gate on street_alchemy tier.

  # TODO: [Chrome & Meat v1 — Milestone 2] install(player, implant_key):
  #   Deterministic-by-inputs install (no RNG in v1). Requires the player to own the uninstalled
  #   implant item (inventory) and not already have it installed. Returns effects:
  #     [{:inventory, implant_key, -1}, {:install_implant, implant_key},
  #      {:chrome_load, def.chrome_load}, {:heat, def.heat_on_install}]
  #   Outcome text/quality may vary by inputs (tier, a suppressant raw on hand) but the EFFECTS are
  #   deterministic. Emergency/RNG surgery is deferred to v2.

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
