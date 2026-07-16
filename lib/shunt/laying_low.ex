defmodule Shunt.LayingLow do
  @moduledoc """
  The Laying Low character mode (see priv/docs/SHUNT_laying_low_v2.md), first mode of the reusable
  Character Mode System. Pure resolvers taking a `%Player{}` and returning
  `{:ok, effects}` / `{:ok, effects, meta}` / `{:error, reason}`, dispatched via
  `Shunt.Players.dispatch/2` like every other action — this module never mutates state.

  While laying low, the player runs a small loop of low-profile activities that advance world time
  (banking income reservoir via `{:advance_time, hours}`) and bleed Heat down. Entry is gated on
  excessive Heat; the mode is stored on `player.mode` and read back through the `{:mode, m}`
  requirements predicate.
  """

  alias Shunt.Heat
  alias Shunt.Players.Player

  @mode "laying_low"

  # Entry requires Heat at the :medium band or above — the "excessive Heat" the mode responds to.
  @entry_bands [:medium, :high]

  # Per-activity tuning: {heat_reduction, hours}. Treated as balancing parameters, not fixed rules.
  @rest {5, 6}
  @gather_rumors {3, 4}
  @visit_contact {5, 6}
  @train {2, 8}
  @burn_evidence {15, 4}
  @burn_evidence_scrip_cost 25

  @doc "Whether the player is currently laying low."
  def laying_low?(%Player{mode: @mode}), do: true
  def laying_low?(%Player{}), do: false

  @doc "Whether the player's Heat is high enough to enter Laying Low."
  def can_enter?(%Player{heat: heat}), do: Heat.band_for(heat) in @entry_bands

  @doc """
  Enter Laying Low. Free flip (the legacy `Players.lay_low/1` cred spend is separate) gated on
  excessive Heat.
  """
  def enter(%Player{} = player) do
    if can_enter?(player) do
      {:ok, [{:set, :mode, @mode}]}
    else
      {:error, :heat_too_low}
    end
  end

  @doc "Leave Laying Low, returning to the normal interaction loop."
  def leave(%Player{mode: @mode}), do: {:ok, [{:set, :mode, nil}]}
  def leave(%Player{}), do: {:error, :not_laying_low}

  @doc "Passive recovery: advance time, small Heat reduction."
  def rest(%Player{} = player), do: activity(player, @rest, "You keep your head down and rest.")

  @doc "Work the information networks while hidden: advance time, small Heat reduction."
  def gather_rumors(%Player{} = player) do
    activity(player, @gather_rumors, "You put an ear to the ground without showing your face.")
  end

  @doc "Maintain a relationship out of public view: advance time, moderate Heat reduction."
  def visit_contact(%Player{} = player) do
    activity(player, @visit_contact, "You call in quiet, keeping the meet off the grid.")
  end

  @doc "Turn downtime toward long-term progression: advance time, small Heat reduction."
  def train(%Player{} = player) do
    activity(player, @train, "You drill the work until your hands stop shaking.")
  end

  @doc """
  Actively destroy evidence to shed Heat: advance time, large Heat reduction, at a scrip cost. Gated
  on affording the cost.
  """
  def burn_evidence(%Player{mode: mode}) when mode != @mode, do: {:error, :not_laying_low}

  def burn_evidence(%Player{scrip: scrip}) when scrip < @burn_evidence_scrip_cost do
    {:error, :insufficient_scrip}
  end

  def burn_evidence(%Player{}) do
    {heat, hours} = @burn_evidence

    {:ok, [{:advance_time, hours}, {:heat, -heat}, {:scrip, -@burn_evidence_scrip_cost}],
     %{narrative: "You feed the paper trail to the incinerator, one file at a time."}}
  end

  # Baseline activity: gated on being in the mode, returns {:advance_time, hours} + {:heat, -n} and a
  # narrative line. Themed/interruption event pools (Phase 3) layer on top of this later.
  defp activity(%Player{mode: @mode}, {heat, hours}, narrative) do
    {:ok, [{:advance_time, hours}, {:heat, -heat}], %{narrative: narrative}}
  end

  defp activity(%Player{}, _tuning, _narrative), do: {:error, :not_laying_low}
end
