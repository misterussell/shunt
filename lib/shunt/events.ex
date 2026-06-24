defmodule Shunt.Events do
  @moduledoc false

  alias Shunt.Content

  def get!(id), do: Content.fetch!(:events, id)

  def all, do: Content.all(:events)

  def current_step(player, event_id) do
    event = get!(event_id)

    case get_in(player.event_state, [event_id, "current_step"]) do
      nil ->
        List.first(event.steps)

      step_id ->
        find_step!(event, step_id)
    end
  end

  def start(player, event_id) do
    event = get!(event_id)
    first_step = List.first(event.steps)

    {:ok, [{:set, :event_state, put_step(player.event_state, event_id, first_step.id)}], %{}}
  end

  def choose(player, event_id, choice_label) do
    if event_id in player.completed_events do
      {:error, :already_completed}
    else
      step = current_step(player, event_id)

      case Enum.find(step.choices, &(&1.label == choice_label)) do
        nil -> {:error, :invalid_choice}
        choice -> resolve_choice(player, event_id, choice)
      end
    end
  end

  defp resolve_choice(player, event_id, %{complete: true}) do
    complete_event(player, event_id)
  end

  defp resolve_choice(player, event_id, %{next: next_id}) do
    {:ok, [{:set, :event_state, put_step(player.event_state, event_id, next_id)}], %{}}
  end

  defp resolve_choice(player, event_id, _choice) do
    {:ok, [{:set, :event_state, Map.delete(player.event_state, event_id)}], %{}}
  end

  defp complete_event(player, event_id) do
    new_completed = Enum.uniq([event_id | player.completed_events])
    new_state = Map.delete(player.event_state, event_id)

    {:ok, [{:set, :completed_events, new_completed}, {:set, :event_state, new_state}], %{}}
  end

  defp put_step(event_state, event_id, step_id) do
    Map.put(event_state, event_id, %{"current_step" => step_id})
  end

  defp find_step!(event, step_id) do
    Enum.find(event.steps, &(&1.id == step_id)) ||
      raise "unknown step #{inspect(step_id)} for event #{inspect(event.id)}"
  end
end
