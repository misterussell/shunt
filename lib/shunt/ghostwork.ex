defmodule Shunt.Ghostwork do
  @moduledoc """
  Ghostwork context: the pure ICE-breaking encounter engine.

  All randomness lives here (global `:rand`, like `Shunt.Npcs.Loyalty`) so the
  LiveView stays deterministic. Each entry point returns an updated
  `%Shunt.Ghostwork.Encounter{}` plus the effects the caller must dispatch through
  `Shunt.Players` — the LiveView never computes progress/trace/outcomes itself.

  See priv/docs/SHUNT_ghostwork_v1.md ("The ICE Encounter").
  """

  alias Shunt.Ghostwork.Encounter

  # --- Tuning constants (all encounter tuning lives here; see doc "Tuning is content") ---

  # Probe: innate, always-available action — small Progress, small Trace.
  @probe_progress 3
  @probe_trace 4

  # Bust threshold: Trace at/above this ends the encounter as a bust.
  @trace_bust 100

  # Bust Heat = base + per-layer * layer_index (deeper busts hurt more).
  @bust_heat_base 12
  @bust_heat_per_layer 4

  # Mastery fog-of-war thresholds (per-family crack count).
  @mastery_numbers 1
  @mastery_weakness 3

  # TODO: begin_encounter(player, node) -> {:ok, %Encounter{}, effects} | {:error, reason}.
  #   Reads the node's per-node state from player.ghostwork_state["nodes"][node.id]
  #   (default %{"banked_layer" => -1, "hardened" => false}).
  #   * start layer_index = banked_layer + 1. If that is >= length(node.layers) the node is
  #     already fully cracked -> {:error, :already_cracked}.
  #   * Hardened gating (lazy clear, no timers): if hardened and player.heat >= node.cool_threshold
  #     -> {:error, :hardened}. If hardened and player.heat < node.cool_threshold, proceed AND
  #     include {:ghostwork_node, node.id, :clear_hardened} in the returned effects. If not
  #     hardened, effects is [].
  #   * mastery snapshot = player.ghostwork_state["mastery"][node.family] (default 0).
  #   * Returns the %Encounter{node: node, layer_index: start, mastery: mastery,
  #     progress: 0, trace: 0, status: :active} and the effects list.

  # TODO: act(encounter, player, action) -> {:ok, %Encounter{}, effects} | {:error, reason},
  #   where action is :probe or {:program, program_id}. Only valid on an :active encounter.
  #   Resolve the action profile (progress, trace):
  #     * :probe -> %{progress: @probe_progress, trace: @probe_trace}. Probe is untyped, so it
  #       never triggers a layer weakness.
  #     * {:program, id} -> fetch via Shunt.Ghostwork.Programs.fetch!/1; if the player doesn't
  #       own it (Programs.owned/1) -> {:error, :program_not_owned}. The current layer is
  #       Enum.at(node.layers, layer_index). If the program's :action == layer.weakness, use its
  #       :on_weakness profile (progress/trace); otherwise its base :progress/:trace.
  #   Compute gains:
  #     * progress_gain = profile.progress (exact, no jitter).
  #     * trace_base = round(profile.trace * layer.trace_multiplier) (deeper layers cost more).
  #     * trace_gain = jittered trace_base: jitter = max(1, div(trace_base, 2)),
  #       Enum.random((max(1, trace_base - jitter))..(trace_base + jitter)). This is the only RNG.
  #   new_progress = progress + progress_gain; new_trace = trace + trace_gain.
  #   Resolve outcome (bust takes priority over a same-action crack):
  #     * BUST — new_trace >= @trace_bust: status :busted, trace capped at @trace_bust, current
  #       layer progress lost. Effects: [{:heat, bust_heat(layer_index)},
  #       {:ghostwork_node, node.id, :harden}]. (Earlier layers were already banked.)
  #     * LAYER CRACKED — new_progress >= layer.progress_required: effects = layer.reward ++
  #       [{:ghostwork_mastery, node.family, 1}, {:ghostwork_node, node.id, {:bank_layer, layer_index}}].
  #       If layer_index + 1 >= length(node.layers): status :cracked (node fully owned),
  #       progress 0, trace carries. Otherwise: status :active, layer_index + 1, progress 0,
  #       trace carries (new_trace) so the next layer's trace_multiplier applies to fresh actions.
  #     * CONTINUE — otherwise: status :active, same layer, progress new_progress, trace new_trace,
  #       effects [].

  # TODO: retreat(encounter) -> {:ok, %Encounter{} (status :retreated), []}. Walk clean: banked
  #   layers were already applied, so retreat emits no effects and no Heat.

  # TODO: numbers_known?(encounter) -> encounter.mastery >= @mastery_numbers. Presentation read
  #   for the LiveView fog-of-war: when false, action Progress/Trace render as "?".

  # TODO: weakness_known?(encounter) -> encounter.mastery >= @mastery_weakness. When false, the
  #   current layer's :weakness is hidden in the UI.

  # TODO: bust_heat(layer_index) -> @bust_heat_base + @bust_heat_per_layer * layer_index. Private
  #   helper used by act/3's bust branch.
end
