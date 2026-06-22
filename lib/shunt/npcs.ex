defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Npcs.Store
  alias Shunt.Players.Player
  alias Shunt.Repo

  # TODO: once the Loyalty wiring below is implemented, add
  # `alias Shunt.Npcs.Loyalty` and `alias Shunt.Npcs.Signals` here.

  @flesh_tithe_input_raw_key "cracked_bone_plate"
  @flesh_tithe_gain_scrip 15
  @flesh_tithe_heat_cost 5

  def list do
    Enum.sort_by(Store.all(), & &1.name)
  end

  def get!(key) do
    Store.fetch!(key)
  end

  # TODO: Wire NPC Loyalty into flesh_tithe/1:
  #   - Define `@flesh_tithe_npc_key "mother_graft"` as a module attribute near the other
  #     @flesh_tithe_* attributes above
  #   - Before the insufficient_materials guard, also check
  #     `not Loyalty.roll_reliable?(player, @flesh_tithe_npc_key)` -> {:error, :npc_unreliable}
  #     (no resources spent, no loyalty change on this branch)
  #   - Scale @flesh_tithe_gain_scrip by Loyalty.price_multiplier(player, @flesh_tithe_npc_key),
  #     floor()'d, instead of using the flat constant directly for the scrip gain
  #   - After computing final_heat/event as today, call
  #     interaction = Loyalty.record_interaction(player, @flesh_tithe_npc_key) and add
  #     npc_loyalty: interaction.npc_loyalty into the same Ecto.Changeset.change/2 map as
  #     inventory/scrip/heat
  #   - with_event/2 below returns a 3-tuple ({:ok, player, event}), so this function can't
  #     use the tap_loyalty_signals/3 helper sketched below (that one's for the plain 2-tuple
  #     {:ok, player} | {:error, reason} the other 4 trade actions return). Instead, match on
  #     the `|> Repo.update() |> with_event(event)` result directly:
  #       case result do
  #         {:ok, player, event} -> emit_loyalty_signals(@flesh_tithe_npc_key, interaction); {:ok, player, event}
  #         {:error, reason} -> {:error, reason}
  #       end
  def flesh_tithe(%Player{} = player) do
    if Map.get(player.inventory, @flesh_tithe_input_raw_key, 0) < 1 do
      {:error, :insufficient_materials}
    else
      {final_heat, event} =
        Heat.resolve(player.heat, Heat.clamp(player.heat + @flesh_tithe_heat_cost))

      player
      |> Ecto.Changeset.change(%{
        inventory: Map.update!(player.inventory, @flesh_tithe_input_raw_key, &(&1 - 1)),
        scrip: player.scrip + @flesh_tithe_gain_scrip,
        heat: final_heat
      })
      |> Repo.update()
      |> with_event(event)
    end
  end

  defp with_event({:ok, player}, event), do: {:ok, player, event}
  defp with_event({:error, reason}, _event), do: {:error, reason}

  # TODO: Add two private helpers, used by all 5 trade-action functions in this module:
  #   defp emit_loyalty_signals(npc_key, interaction) do
  #     if interaction.met_for_first_time, do: Signals.npc_met(npc_key)
  #
  #     if interaction.old_band != interaction.new_band do
  #       Signals.loyalty_band_changed(npc_key, interaction.old_band, interaction.new_band)
  #     end
  #   end
  #
  #   defp tap_loyalty_signals({:ok, player} = result, npc_key, interaction) do
  #     emit_loyalty_signals(npc_key, interaction)
  #     result
  #   end
  #   defp tap_loyalty_signals({:error, _reason} = result, _npc_key, _interaction), do: result
  # `interaction` is the map returned by Loyalty.record_interaction/2. Pipe a trade action's
  # `... |> Repo.update()` result through `|> tap_loyalty_signals(npc_key, interaction)` to
  # emit signals only on success while returning the tuple unchanged — used by move_goods/1,
  # look_the_other_way/1, data_drop/1, and settle_the_books/1 below (all of which return a
  # plain {:ok, player} | {:error, reason} from Repo.update, unlike flesh_tithe/1 above).

  def move_goods(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  # TODO: Wire NPC Loyalty into move_goods/1:
  #   - Define `@move_goods_npc_key "rook"` as a module attribute above
  #   - After the no_held_item guard, also check
  #     `not Loyalty.roll_reliable?(player, @move_goods_npc_key)` -> {:error, :npc_unreliable}
  #   - Scale the 0.5 sell_value cut by Loyalty.price_multiplier(player, @move_goods_npc_key)
  #     before floor()'ing, e.g. `floor(item.sell_value * 0.5 * Loyalty.price_multiplier(player, @move_goods_npc_key))`
  #   - Call interaction = Loyalty.record_interaction(player, @move_goods_npc_key), add
  #     npc_loyalty: interaction.npc_loyalty to the changeset alongside scrip/held_item_key
  #   - On success, call emit_loyalty_signals(@move_goods_npc_key, interaction) before
  #     returning {:ok, player}
  def move_goods(%Player{held_item_key: key} = player) do
    item = Shunt.Fencing.Catalog.fetch!(key)
    payout = floor(item.sell_value * 0.5)

    player
    |> Ecto.Changeset.change(%{scrip: player.scrip + payout, held_item_key: nil})
    |> Repo.update()
  end

  @look_the_other_way_cost_scrip 20
  @look_the_other_way_heat_reduction 15

  # TODO: Wire NPC Loyalty into look_the_other_way/1. Define
  # `@look_the_other_way_npc_key "nine_iron"` as a module attribute above. The scaled cost
  # now depends on player.npc_loyalty (not just a literal), which guard clauses can't call
  # Loyalty.cost_multiplier/2 to compute (guards only allow a restricted BIF set) — collapse
  # the two function heads below into a single look_the_other_way(%Player{} = player) clause
  # and do the checks inside the body with cond/if instead:
  #   cost = ceil(@look_the_other_way_cost_scrip * Loyalty.cost_multiplier(player, @look_the_other_way_npc_key))
  #   cond do
  #     player.scrip < cost -> {:error, :insufficient_scrip}
  #     not Loyalty.roll_reliable?(player, @look_the_other_way_npc_key) -> {:error, :npc_unreliable}
  #     true ->
  #       interaction = Loyalty.record_interaction(player, @look_the_other_way_npc_key)
  #       player
  #       |> Ecto.Changeset.change(%{
  #         scrip: player.scrip - cost,
  #         heat: Heat.clamp(player.heat - @look_the_other_way_heat_reduction),
  #         npc_loyalty: interaction.npc_loyalty
  #       })
  #       |> Repo.update()
  #       |> tap_loyalty_signals(@look_the_other_way_npc_key, interaction)
  #   end
  # heat reduction is unaffected by the multiplier (not a price). tap_loyalty_signals/3 is
  # the shared helper defined near with_event/2 above.
  def look_the_other_way(%Player{scrip: scrip}) when scrip < @look_the_other_way_cost_scrip,
    do: {:error, :insufficient_scrip}

  def look_the_other_way(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip - @look_the_other_way_cost_scrip,
      heat: Heat.clamp(player.heat - @look_the_other_way_heat_reduction)
    })
    |> Repo.update()
  end

  @data_drop_cost_scrip 20
  @data_drop_gain_cred 1

  # TODO: Wire NPC Loyalty into data_drop/1. Define `@data_drop_npc_key "splice"` as a
  # module attribute above. Same restructuring as look_the_other_way/1 above (cost now
  # depends on player.npc_loyalty, so collapse the two function heads below into one and
  # check inside the body with cond):
  #   cost = ceil(@data_drop_cost_scrip * Loyalty.cost_multiplier(player, @data_drop_npc_key))
  #   gain = floor(@data_drop_gain_cred * Loyalty.price_multiplier(player, @data_drop_npc_key))
  #   cond do
  #     player.scrip < cost -> {:error, :insufficient_scrip}
  #     not Loyalty.roll_reliable?(player, @data_drop_npc_key) -> {:error, :npc_unreliable}
  #     true ->
  #       interaction = Loyalty.record_interaction(player, @data_drop_npc_key)
  #       player
  #       |> Ecto.Changeset.change(%{
  #         scrip: player.scrip - cost,
  #         cred: player.cred + gain,
  #         npc_loyalty: interaction.npc_loyalty
  #       })
  #       |> Repo.update()
  #       |> tap_loyalty_signals(@data_drop_npc_key, interaction)
  #   end
  # Note @data_drop_gain_cred is only 1 to start — floor(1 * 1.2) == 1, so the favored-band
  # bonus won't show up until cred gains are larger; that's a tuning question, not a bug.
  def data_drop(%Player{scrip: scrip}) when scrip < @data_drop_cost_scrip,
    do: {:error, :insufficient_scrip}

  def data_drop(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip - @data_drop_cost_scrip,
      cred: player.cred + @data_drop_gain_cred
    })
    |> Repo.update()
  end

  @settle_the_books_cost_cred 1
  @settle_the_books_gain_scrip 10

  # TODO: Wire NPC Loyalty into settle_the_books/1. Define
  # `@settle_the_books_npc_key "tally"` as a module attribute above. Same restructuring as
  # look_the_other_way/1 above (cost now depends on player.npc_loyalty, so collapse the two
  # function heads below into one and check inside the body with cond):
  #   cost = ceil(@settle_the_books_cost_cred * Loyalty.cost_multiplier(player, @settle_the_books_npc_key))
  #   gain = floor(@settle_the_books_gain_scrip * Loyalty.price_multiplier(player, @settle_the_books_npc_key))
  #   cond do
  #     player.cred < cost -> {:error, :insufficient_cred}
  #     not Loyalty.roll_reliable?(player, @settle_the_books_npc_key) -> {:error, :npc_unreliable}
  #     true ->
  #       interaction = Loyalty.record_interaction(player, @settle_the_books_npc_key)
  #       player
  #       |> Ecto.Changeset.change(%{
  #         cred: player.cred - cost,
  #         scrip: player.scrip + gain,
  #         npc_loyalty: interaction.npc_loyalty
  #       })
  #       |> Repo.update()
  #       |> tap_loyalty_signals(@settle_the_books_npc_key, interaction)
  #   end
  def settle_the_books(%Player{cred: cred}) when cred < @settle_the_books_cost_cred,
    do: {:error, :insufficient_cred}

  def settle_the_books(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      cred: player.cred - @settle_the_books_cost_cred,
      scrip: player.scrip + @settle_the_books_gain_scrip
    })
    |> Repo.update()
  end
end
