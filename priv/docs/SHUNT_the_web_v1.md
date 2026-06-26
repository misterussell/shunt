<!-- TODO: Rewrite this doc to match the implemented v1 and the agreed design:
     - currency :scrip (not :credits); real event model (steps/choices/on_complete)
     - the arc-spine (linear npc_progression) vs requirement-reveal split
     - real keywords: rewards {:modify_rep, npc, dim, n}/{:knowledge, k}/{:contact, k};
       requirements {:knows, k}/{:rep_at_least, npc, dim, n}/{:contact_known, k}
     - new Player fields reputation/knowledge/contacts; Shunt.Requirements evaluator
     - hide-entirely gating; Juno as the worked example with one knowledge reveal
       (gated location) and one trust reveal (gated exit)
     Keep the Design Philosophy and Future Phase sections. -->

# Shunt Feature Proposal: The Web (Social & Criminal Networks)

## Goal

Implement the first version of **The Web** skill as a data-driven progression layer that sits on top of the existing NPC and Event systems.

The Web should not introduce a separate quest engine, relationship engine, or social graph system.

Instead, it should:

* Reuse existing event content
* Reuse existing event progression
* Introduce new reward and requirement types
* Track player relationships, favors, knowledge, and contacts
* Unlock new content through social progression

The player fantasy is:

> Build trust, collect favors, learn secrets, discover contacts, and leverage those relationships to access opportunities unavailable to other players.

---

# Design Philosophy

The Web is not content.

NPCs and Events remain the primary content containers.

The Web is a progression layer that modifies what content becomes available.

Current model:

```text
NPC
 └─ Events
      └─ Rewards
```

Expanded model:

```text
NPC
 └─ Events
      ├─ Rewards
      │    ├─ Credits
      │    ├─ Items
      │    ├─ Trust
      │    ├─ Favors
      │    ├─ Knowledge
      │    └─ Contacts
      │
      └─ Requirements
           ├─ Trust
           ├─ Favors
           ├─ Knowledge
           └─ Contacts
```

---

# Player State

Add a generalized Web ledger to player progression.

Example:

```elixir
%{
  reputation: %{
    "juno" => %{
      trust: 25,
      favors: 2
    }
  },

  knowledge: MapSet.new(),

  contacts: MapSet.new()
}
```

This intentionally avoids dedicated structs such as:

```elixir
%ContactState{}
%Rumor{}
%Relationship{}
```

All progression should be data-driven.

---

# New Reward Types

## Trust

Increase relationship strength with an NPC.

```elixir
{:modify_rep, "juno", :trust, 5}
```

---

## Favor

Represents a debt owed by an NPC.

```elixir
{:modify_rep, "juno", :favors, 1}
```

---

## Knowledge

Represents discovered information.

```elixir
{:knowledge, "juno_secret_supplier"}
```

---

## Contact Discovery

Unlocks new contacts.

```elixir
{:contact, "rose_broker"}
```

---

# New Requirement Types

## Trust Requirement

```elixir
{:rep_at_least, "juno", :trust, 20}
```

---

## Favor Requirement

```elixir
{:rep_at_least, "juno", :favors, 1}
```

---

## Knowledge Requirement

```elixir
{:knows, "juno_secret_supplier"}
```

---

## Contact Requirement

```elixir
{:contact_known, "rose_broker"}
```

---

# Example Implementation

This example demonstrates a complete Web progression path using a single NPC.

The example intentionally leaves an opening for a future second NPC connection.

---

# NPC: Juno

Role:

* Smuggler
* Bazaar regular
* Small-time contraband broker

Initial state:

```elixir
player.reputation["juno"] = %{
  trust: 0,
  favors: 0
}
```

---

# Event 1: Move a Package

Available immediately.

```elixir
%Event{
  id: "juno_move_package",

  requirements: [],

  rewards: [
    {:credits, 50},
    {:modify_rep, "juno", :trust, 10}
  ]
}
```

Narrative:

Player delivers a package across Shunt 9.

Result:

```text
Trust with Juno +10
```

---

# Event 2: Quiet Pickup

Unlocked through trust.

```elixir
%Event{
  id: "juno_quiet_pickup",

  requirements: [
    {:rep_at_least, "juno", :trust, 10}
  ],

  rewards: [
    {:modify_rep, "juno", :trust, 10},
    {:modify_rep, "juno", :favors, 1}
  ]
}
```

Narrative:

Juno trusts the player with a sensitive pickup.

Result:

```text
Trust with Juno +10
Favor with Juno +1
```

Player state:

```elixir
"juno" => %{
  trust: 20,
  favors: 1
}
```

---

# Event 3: Call In a Favor

Consumes a favor.

```elixir
%Event{
  id: "juno_need_safehouse",

  requirements: [
    {:rep_at_least, "juno", :favors, 1}
  ],

  effects: [
    {:modify_rep, "juno", :favors, -1}
  ],

  rewards: [
    {:knowledge, "juno_secret_supplier"}
  ]
}
```

Narrative:

Juno arranges temporary shelter and accidentally reveals useful information.

Result:

```text
Favor Spent
Knowledge Gained:
juno_secret_supplier
```

---

# Event 4: Supplier Investigation

Unlocked through discovered knowledge.

```elixir
%Event{
  id: "juno_supplier_investigation",

  requirements: [
    {:knows, "juno_secret_supplier"}
  ],

  rewards: [
    {:credits, 150},
    {:modify_rep, "juno", :trust, 10}
  ]
}
```

Player state:

```elixir
"juno" => %{
  trust: 30,
  favors: 0
}
```

---

# Expansion Hook: Second NPC Connection

This is the first point where the social network begins to emerge.

Future content can introduce:

```elixir
{:contact, "rose_broker"}
```

through completion of the supplier investigation.

Example future reward:

```elixir
rewards: [
  {:contact, "rose_broker"}
]
```

Result:

```text
New Contact Discovered:
Rose the Broker
```

This creates the first edge in the social network:

```text
Juno
  ↓
introduces
  ↓
Rose
```

Importantly, no graph system is required.

The connection is represented entirely through content.

---

# Future Phase (Not In Scope)

The following systems should be deferred until this foundation is proven fun:

* Explicit relationship graphs
* Faction influence networks
* Rumor boards
* Social manipulation systems
* Gang politics simulation
* Dynamic leverage generation
* Contact loyalty decay

The first implementation should focus entirely on:

```text
Events
  ↓
Trust
  ↓
Favors
  ↓
Knowledge
  ↓
Contacts
  ↓
More Events
```

If that loop proves engaging, additional Web systems can be layered on top without replacing the underlying architecture.
