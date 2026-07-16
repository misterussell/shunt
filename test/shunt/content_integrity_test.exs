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

    # Collect grants from all events' on_complete, plus ICE node layer rewards — a cracked
    # Ghostwork layer dispatches its reward exactly like an event's on_complete, so a knowledge
    # key a node grants is just as valid a gate source (e.g. "maintenance_log_decoded").
    ice_node_rewards =
      Content.all(:ice_nodes)
      |> Enum.flat_map(& &1.layers)
      |> Enum.flat_map(&Map.get(&1, :reward, []))

    all_effects = Enum.flat_map(all_events, & &1.on_complete) ++ ice_node_rewards

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

  test "every contact (NPC with services) has a contact_key" do
    # Loyalty and the Hub's deal buttons are keyed by contact_key (see Shunt.Contacts). A contact
    # authored with services but no contact_key would surface a dead deal button — its click posts
    # an empty contact and resolves to {:error, :unknown_contact}. Guard against that here.
    contacts_without_key =
      Content.all(:world_npcs)
      |> Enum.filter(&(&1.services != [] and is_nil(&1.contact_key)))
      |> Enum.map(& &1.name)

    assert contacts_without_key == [],
           "contact NPCs with services but no contact_key: #{inspect(contacts_without_key)}"
  end

  test "every contact service unlock flag is granted by some event" do
    # A contact's tiered services gate on {:knows, "<key>"} flags (see Shunt.Contacts). Every such
    # flag must be granted somewhere, or that tier is unreachable — the player could never unlock it.
    granted_knowledge =
      Events.all()
      |> Enum.flat_map(& &1.on_complete)
      |> then(fn effects -> MapSet.new(for {:knowledge, k} <- effects, do: k) end)

    service_flags =
      Content.all(:world_npcs)
      |> Enum.flat_map(& &1.services)
      |> Enum.flat_map(& &1.requirements)
      |> then(fn reqs -> MapSet.new(for {:knows, k} <- reqs, do: k) end)

    assert MapSet.subset?(service_flags, granted_knowledge),
           "service unlock flags with no granting event: #{inspect(MapSet.difference(service_flags, granted_knowledge) |> MapSet.to_list())}"
  end
end
