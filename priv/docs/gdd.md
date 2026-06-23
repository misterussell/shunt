# Shunt — Game Design Document
## Initial Lore & Progression Reference

> **Status:** Early concept. Use this document to establish shared context for all agents working on the project.

---

## Overview

**Shunt** is a cyberpunk-themed incremental crafting game. The player starts as a small-time fence in the criminal underworld of a sprawling megacity and rises through society by building skills, relationships, and resources. Core themes are drawn from William Gibson's Sprawl series: hacking, body modification, black markets, corporate power, and the tension between identity and ambition.

---

## The Setting: Kaspav

A megacity-state built on the ruins of three collapsed nations. Kaspav is stratified into literal vertical **strata**:

- **The Spires** — gleaming tower-tops where the wealthy and powerful live
- **The Midgrid** — the aspirational middle layer, anxious and easy to exploit
- **The Underbelly** — a labyrinthine maze of sub-street tunnels, repurposed infrastructure, and black-market ecosystems

The city's omnipresent data layer is called **the Latticework** — a surveillance and communications mesh that underpins nearly every aspect of life in Kaspav.

---

## The Player Character

The player begins as a **Warez Runner** — a fence who moves stolen goods, data, and black-market tech through the Underbelly's informal economy. No direct theft, no hacking (yet). Just contacts, instincts, and leverage.

**Starting location:** Shunt 9 — a gutted transit node and former subway interchange that has become an informal bazaar where contraband changes hands under flickering bioluminescent strip lighting.

The macro arc of the game is the player rising from a nobody in the Underbelly to a power player in the Spires — and grappling with what they had to become along the way.

---

## Core Resources

Three resources drive all activity:

| Resource | Description |
|----------|-------------|
| **Cred** | Social currency. Reputation made liquid. Spent to open doors, bribe officials, and buy into higher-tier networks. |
| **Scrip** | Hard cash (physical and crypto). Pays for materials, bribes, and upgrades. |
| **Heat** | Unwanted attention from authorities, rivals, and factions. A hidden pressure meter — too much Heat triggers negative events. |

---

## Skill Trees

Four skill trees define how the player interacts with the world. Skills decay slightly if neglected — the player must commit to an identity.

### Ghostwork *(Hacking & ICE-breaking)*
Interfacing with the Latticework. Ranges from skimming corporate feeds to cracking military-grade ICE. Key NPCs: rogue AIs, corp data brokers, burned netrunners.

### Chrome & Meat *(Body Modification)*
Sourcing, installing, and trading illegal augmentations — subdermal tools, neural ports, black-market reflex boosters. The line between upgrade and addiction gets blurry fast. Key NPCs: back-alley surgeons called **Graftsmen**, augmentation smugglers, and a body-mod cult called **the Fleshless**.

### The Web *(Social & Criminal Networks)*
Reading people, building leverage, and calling in favors. Knowing which gang controls which tunnel, which corp fixer is for sale, which official has a dirty secret. Key NPCs: gang lieutenants, corrupt Kaspav Authority officers, information brokers.

### Street Alchemy *(Salvage & Crafting)*
Breaking down scavenged tech and rebuilding it into something valuable. Most people in the Underbelly consume — they don't create. Key NPCs: scrapyard operators, rogue engineers, and **Patchworkers** (wandering repair-monks who know old-world manufacturing techniques).

---

## Factions

| Faction | Description |
|---------|-------------|
| **Syndicate of Closed Hands** | The Underbelly's dominant criminal infrastructure. They tax everything. The player currently pays them. |
| **Kaspav Authority (KA)** | Militarized city police, deeply corrupt and for hire to the highest Spire bidder. |
| **The Latticework Collective** | A decentralized hacker collective with no clear leadership and strong opinions about corporate data monopolies. |
| **Meridian Corp** | The most powerful of Kaspav's three ruling megacorps. Fingers in augmentation, surveillance, and private security. |
| **The Fleshless** | A body-mod cult who believe biological humanity is a design flaw. Unsettling. Occasionally useful. |

Each faction has a reputation track: **Unknown → Tolerated → Useful → Trusted → Indebted → Embedded**. High standing with one faction often poisons standing with another.

---

## The Four Progression Ladders

### Ladder 1: Territory
The player's physical footprint in Kaspav.

| Tier | Status | What It Unlocks |
|------|--------|-----------------|
| 1 | Squatter | A corner of Shunt 9. Basic fencing. |
| 2 | Tenant | A locked stall. Storage, basic crafting bench. |
| 3 | Operator | A proper safehouse. NPC employees, passive income. |
| 4 | Node | A recognized hub. Faction reps come to the player. |
| 5 | Kingpin | The player *is* infrastructure. The Underbelly routes through them. |

### Ladder 2: Skill Depth
Each skill tree has five tiers unlocked through use and investment. Early tiers are cheap but low-yield. Later tiers require rare components, NPC relationships, or high-risk events to unlock.

### Ladder 3: Social Standing
The macro arc of the game.

| Tier | Stratum | How the Player Is Seen |
|------|---------|------------------------|
| 1 | Underbelly | A nobody with useful contacts |
| 2 | Underbelly (known) | A player. Factions take calls. |
| 3 | Midgrid | Has a legal identity. Possibly fake. |
| 4 | Midgrid (established) | Corps notice them. Doors open — and close. |
| 5 | Spire-adjacent | Dangerous enough to be invited in. |
| 6 | Spire | Became what they used to fence for. |

### Ladder 4: Faction Standing
Tracked independently per faction (see Factions above). Unlocks unique crafting recipes, NPC contacts, and territory access.

---

## The Crafting Engine

Items exist in four tiers of increasing complexity and value:

| Tier | Description |
|------|-------------|
| **Raw** | Stolen, scavenged, or bought cheap. Thin margins. |
| **Assembled** | Combined from Raws using a skill recipe. Better margins. |
| **Modded** | Augmented with firmware or hardware modifications. Requires Ghostwork or Chrome & Meat skills. |
| **Bespoke** | One-of-a-kind items built to an NPC's specification. Highest value. Unlocks unique rewards and deepens relationships. |

**Bespoke commissions** function as the game's primary quest format: an NPC needs something specific, the player sources components, protects the supply chain, and delivers under pressure.

---

## Pressure Systems

Three rotating systems create friction and prevent idle play from dominating:

**Heat Events** — when Heat crosses a threshold, a random event fires (KA raids a stash, a rival undercuts prices, the Syndicate renegotiates). Mitigated by spending Cred or calling in faction favors.

**Market Shifts** — Kaspav's black market fluctuates based on in-world events. A corp crackdown drives up Chrome & Meat prices. A Latticework data dump floods the market with cheap ICE tools. Players who read the market and adapt their crafting get ahead faster.

**NPC Loyalty** — key NPCs have loyalty meters. Ignoring or overexposing them causes them to become unreliable, raise prices, or disappear. The most valuable NPCs are the hardest to keep.

---

## Endgame Framing

By Spire-adjacent standing, the game surfaces a central question it has been building toward:

> *What did you have to become to get here?*

Skill specialization, faction allegiances, and choices made under pressure have shaped the player's identity. The final tier is not about accumulating more — it is about deciding what to do with the machine that has been built.

---

*Last updated: project kickoff. Expand this document as systems are implemented and design decisions are made.*