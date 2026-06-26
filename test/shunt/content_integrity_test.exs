defmodule Shunt.ContentIntegrityTest do
  use ExUnit.Case, async: true

  alias Shunt.Content
  alias Shunt.Events

  test "every gating key has a granting effect somewhere in content" do
    all_events = Events.all()

    # Collect requirements from events only — this catches errand soft-locks (typo'd
    # item/knowledge keys in event gating). Location and exit requirements are excluded
    # because world-building gates (e.g. {:knows, "rook"}) may exist before their granting
    # events are written; event-level gates are the ones that can silently soft-lock an errand.
    all_requirements = Enum.flat_map(all_events, & &1.requirements)

    # Collect grants from all events' on_complete
    all_effects = Enum.flat_map(all_events, & &1.on_complete)

    granted_items = MapSet.new(for {:inventory, k, n} <- all_effects, n > 0, do: k)
    granted_knowledge = MapSet.new(for {:knowledge, k} <- all_effects, do: k)
    granted_contacts = MapSet.new(for {:contact, k} <- all_effects, do: k)

    quest_item_ids = MapSet.new(Content.all(:quest_items), & &1.id)

    required_items = MapSet.new(for {:has_item, k} <- all_requirements, do: k)
    required_knowledge = MapSet.new(for {:knows, k} <- all_requirements, do: k)
    required_contacts = MapSet.new(for {:contact_known, k} <- all_requirements, do: k)

    assert MapSet.subset?(required_items, granted_items),
           "has_item requirements with no granting event: #{inspect(MapSet.difference(required_items, granted_items) |> MapSet.to_list())}"

    assert MapSet.subset?(required_knowledge, granted_knowledge),
           "knows requirements with no granting event: #{inspect(MapSet.difference(required_knowledge, granted_knowledge) |> MapSet.to_list())}"

    assert MapSet.subset?(required_contacts, granted_contacts),
           "contact_known requirements with no granting event: #{inspect(MapSet.difference(required_contacts, granted_contacts) |> MapSet.to_list())}"

    assert MapSet.subset?(required_items, quest_item_ids),
           "has_item keys not in quest_items catalog: #{inspect(MapSet.difference(required_items, quest_item_ids) |> MapSet.to_list())}"
  end
end
