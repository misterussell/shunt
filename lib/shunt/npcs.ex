defmodule Shunt.Npcs do
  @moduledoc false
  alias Shunt.Heat
  alias Shunt.Npcs.Loyalty
  alias Shunt.Npcs.Signals
  alias Shunt.Npcs.Store
  alias Shunt.Players.Player
  alias Shunt.Repo

  @flesh_tithe_input_raw_key "cracked_bone_plate"
  @flesh_tithe_gain_scrip 15
  @flesh_tithe_heat_cost 5
  @flesh_tithe_npc_key "mother_graft"

  def list do
    Enum.sort_by(Store.all(), & &1.name)
  end

  def get!(key) do
    Store.fetch!(key)
  end

  # TODO: per priv/docs/architecture.md Section 2 & 3, rewrite flesh_tithe/1, move_goods/1,
  # look_the_other_way/1, data_drop/1, and settle_the_books/1 below to return effect lists
  # ({:ok, effects} / {:error, reason}) instead of calling Ecto.Changeset.change/Repo.update
  # and emitting Signals directly. Loyalty band-transition detection and Signals emission move
  # into Shunt.Effects' {:npc_loyalty, npc_key, delta} handling (see lib/shunt/effects.ex) -
  # delete with_event/2, emit_loyalty_signals/2, and tap_loyalty_signals/3 below once every
  # function that used them is converted, along with the `alias Shunt.Repo` and
  # `alias Shunt.Npcs.Signals` lines.

  def flesh_tithe(%Player{} = player) do
    cond do
      not Loyalty.roll_reliable?(player, @flesh_tithe_npc_key) ->
        {:error, :npc_unreliable}

      Map.get(player.inventory, @flesh_tithe_input_raw_key, 0) < 1 ->
        {:error, :insufficient_materials}

      true ->
        # TODO: return {:ok, [{:inventory, @flesh_tithe_input_raw_key, -1},
        # {:heat, @flesh_tithe_heat_cost},
        # {:scrip, floor(@flesh_tithe_gain_scrip * Loyalty.price_multiplier(player, @flesh_tithe_npc_key))},
        # {:npc_loyalty, @flesh_tithe_npc_key, 5}]} (5 is Loyalty's gain amount - see the TODO
        # on Loyalty.record_interaction/2 in lib/shunt/npcs/loyalty.ex)
        {final_heat, event} =
          Heat.resolve(player.heat, Heat.clamp(player.heat + @flesh_tithe_heat_cost))

        gain =
          floor(@flesh_tithe_gain_scrip * Loyalty.price_multiplier(player, @flesh_tithe_npc_key))

        interaction = Loyalty.record_interaction(player, @flesh_tithe_npc_key)

        result =
          player
          |> Ecto.Changeset.change(%{
            inventory: Map.update!(player.inventory, @flesh_tithe_input_raw_key, &(&1 - 1)),
            scrip: player.scrip + gain,
            heat: final_heat,
            npc_loyalty: interaction.npc_loyalty
          })
          |> Repo.update()
          |> with_event(event)

        case result do
          {:ok, player, event} ->
            emit_loyalty_signals(@flesh_tithe_npc_key, interaction)
            {:ok, player, event}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp with_event({:ok, player}, event), do: {:ok, player, event}
  defp with_event({:error, reason}, _event), do: {:error, reason}

  defp emit_loyalty_signals(npc_key, interaction) do
    if interaction.met_for_first_time, do: Signals.npc_met(npc_key)

    if interaction.old_band != interaction.new_band do
      Signals.loyalty_band_changed(npc_key, interaction.old_band, interaction.new_band)
    end
  end

  defp tap_loyalty_signals({:ok, _player} = result, npc_key, interaction) do
    emit_loyalty_signals(npc_key, interaction)
    result
  end

  defp tap_loyalty_signals({:error, _reason} = result, _npc_key, _interaction), do: result

  def move_goods(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  @move_goods_npc_key "rook"

  def move_goods(%Player{held_item_key: key} = player) do
    if Loyalty.roll_reliable?(player, @move_goods_npc_key) do
      item = Shunt.Fencing.Catalog.fetch!(key)

      # TODO: return {:ok, [{:scrip, floor(item.sell_value * 0.5 *
      # Loyalty.price_multiplier(player, @move_goods_npc_key))}, {:set, :held_item_key, nil},
      # {:npc_loyalty, @move_goods_npc_key, 5}]}
      payout =
        floor(item.sell_value * 0.5 * Loyalty.price_multiplier(player, @move_goods_npc_key))

      interaction = Loyalty.record_interaction(player, @move_goods_npc_key)

      player
      |> Ecto.Changeset.change(%{
        scrip: player.scrip + payout,
        held_item_key: nil,
        npc_loyalty: interaction.npc_loyalty
      })
      |> Repo.update()
      |> tap_loyalty_signals(@move_goods_npc_key, interaction)
    else
      {:error, :npc_unreliable}
    end
  end

  @look_the_other_way_cost_scrip 20
  @look_the_other_way_heat_reduction 15
  @look_the_other_way_npc_key "nine_iron"

  def look_the_other_way(%Player{} = player) do
    cost =
      ceil(
        @look_the_other_way_cost_scrip *
          Loyalty.cost_multiplier(player, @look_the_other_way_npc_key)
      )

    cond do
      player.scrip < cost ->
        {:error, :insufficient_scrip}

      not Loyalty.roll_reliable?(player, @look_the_other_way_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        # TODO: return {:ok, [{:scrip, -cost}, {:heat, -@look_the_other_way_heat_reduction},
        # {:npc_loyalty, @look_the_other_way_npc_key, 5}]} - note the heat delta is negative
        # (a reduction); Shunt.Effects' {:heat, delta} handling must clamp at 0 the same way
        # Shunt.Heat.clamp/1 does today.
        interaction = Loyalty.record_interaction(player, @look_the_other_way_npc_key)

        player
        |> Ecto.Changeset.change(%{
          scrip: player.scrip - cost,
          heat: Heat.clamp(player.heat - @look_the_other_way_heat_reduction),
          npc_loyalty: interaction.npc_loyalty
        })
        |> Repo.update()
        |> tap_loyalty_signals(@look_the_other_way_npc_key, interaction)
    end
  end

  @data_drop_cost_scrip 20
  @data_drop_gain_cred 1
  @data_drop_npc_key "splice"

  def data_drop(%Player{} = player) do
    cost = ceil(@data_drop_cost_scrip * Loyalty.cost_multiplier(player, @data_drop_npc_key))
    gain = floor(@data_drop_gain_cred * Loyalty.price_multiplier(player, @data_drop_npc_key))

    cond do
      player.scrip < cost ->
        {:error, :insufficient_scrip}

      not Loyalty.roll_reliable?(player, @data_drop_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        # TODO: return {:ok, [{:scrip, -cost}, {:cred, gain},
        # {:npc_loyalty, @data_drop_npc_key, 5}]}
        interaction = Loyalty.record_interaction(player, @data_drop_npc_key)

        player
        |> Ecto.Changeset.change(%{
          scrip: player.scrip - cost,
          cred: player.cred + gain,
          npc_loyalty: interaction.npc_loyalty
        })
        |> Repo.update()
        |> tap_loyalty_signals(@data_drop_npc_key, interaction)
    end
  end

  @settle_the_books_cost_cred 1
  @settle_the_books_gain_scrip 10
  @settle_the_books_npc_key "tally"

  def settle_the_books(%Player{} = player) do
    cost =
      ceil(
        @settle_the_books_cost_cred * Loyalty.cost_multiplier(player, @settle_the_books_npc_key)
      )

    gain =
      floor(
        @settle_the_books_gain_scrip * Loyalty.price_multiplier(player, @settle_the_books_npc_key)
      )

    cond do
      player.cred < cost ->
        {:error, :insufficient_cred}

      not Loyalty.roll_reliable?(player, @settle_the_books_npc_key) ->
        {:error, :npc_unreliable}

      true ->
        # TODO: return {:ok, [{:cred, -cost}, {:scrip, gain},
        # {:npc_loyalty, @settle_the_books_npc_key, 5}]}
        interaction = Loyalty.record_interaction(player, @settle_the_books_npc_key)

        player
        |> Ecto.Changeset.change(%{
          cred: player.cred - cost,
          scrip: player.scrip + gain,
          npc_loyalty: interaction.npc_loyalty
        })
        |> Repo.update()
        |> tap_loyalty_signals(@settle_the_books_npc_key, interaction)
    end
  end
end
