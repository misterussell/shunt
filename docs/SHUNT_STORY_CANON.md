# Shunt Story Canon

The cross-district story bible: the world's spine, each district's through-line, the threads that
run between them, and the **forward hooks** the next area must honor. This is world-canon, like the
Lexicon — not a per-feature spec. When you build a new area, read this first so you don't contradict
what's already been revealed, and update it when your area reveals something the next one must know.

The Lexicon (`SHUNT_LEXICON.md`) is the source of truth for *terms*; this doc is the source of truth
for *story continuity*. Where they overlap, they must agree.

---

## The spine

The world is vertical. Everyone is climbing, and the higher you get, the closer to the Spire and the
more the climb costs. Strata, bottom to top:

**Underbelly → Liftworks (the seam) → Midgrid → the Spire.**

`graph_position` encodes it: more-negative `y` = higher. The **Kaspav Authority** runs the climb —
permits, checkpoints, readers, ICE — and gets tighter and richer the higher you go. The through-line
question of the whole game is *what is at the top, and what does getting there cost.*

### The district chain (built, in ascent order)

| District | Strata | Through-line | Facts |
|---|---|---|---|
| **Shunt 9** | Underbelly | Starter squat in a dead interchange; scrape a living, get the power back on. | `power` |
| **Crossgate** | Underbelly | Always-open transit interchange; seat of the Syndicate of Closed Hands (debt/paper). | — |
| **Liftworks** | the seam | Authority ascent checkpoint where the Underbelly meets the Midgrid; the Risers, the Cold Stair. | — |
| **Grayline** | Midgrid | The intake margin where **hollows** (people with no echo) pool; the **Echo Court** forges echoes — Latticework identities that let you pass as a citizen. | — |
| **Windlass** | Midgrid | A working city wound up a giant screw-lift; a vertical class war, **Authority vs the Latticework Collective**. The stall was sabotage — a purge laundered as mechanical failure. Player climbs out the Anchor Gate. | `grid`, `haul` |
| **The Bloom** | Midgrid (top) | The last district before the Spire; performed wealth clawing for ascent. **Ascent is a harvest.** (See below — this is the load-bearing reveal.) | `draw`, `season`, `book` |
| **The Winnow** | the Spire (base) | The Spire's first district — the Receiving Floor at the top of the throat, where the harvest is sorted (Keep/Cull) and inducted. A servant caste of kept-whole ascended staffs it under the Authority's wardens; the quota comes from **above the Authority**. (See below — this opens the Spire's spine.) | `quota`, `waking` |
| **The Spire** | top | **Base district built (the Winnow).** The seat of the Authority and the destination of everyone who ascends — but the Winnow reveals the Authority is only a *hand*; something above it writes the quota and eats what the throat sends up. Attaches at the Bloom's Uptake; the Winnow's Head-End dangles the next up-seam. |

---

## Cross-district threads

- **Ascent.** The vertical climb toward the Spire, gated by the Authority at every seam (Liftworks
  checkpoint, Windlass Anchor Gate, Bloom Uptake). Each district gates it; the Bloom reveals what it's
  *for*.
- **Echoes → ghosts.** Grayline establishes **echoes** (forged Latticework identities). The Bloom's
  *believed cover story* is that ascent buys your echo/name and quietly retires you. The **truth** is
  worse: your mind is wired into the Latticework as living substrate. Identity is the currency the
  whole vertical trades in, and the Latticework is where it ends up.
- **The ghosts.** *Ghostdeck, Ghostwork, ghosted* — the game's core vocabulary. The Bloom reveals
  that **the ascended become the ghosts in the Latticework.** Every hack the player has done since
  Shunt 9 has brushed against harvested people. How literal and total this is, is left for the Spire.
- **The Authority.** The one power present at every strata; controls the grid and ascent; tightest
  and richest at the top. The Spire is its seat. The other powers are regional (Closed Hands = debt,
  Collective = the wires, Echo Court = identity, Whisper Syndicate = reputation). **The Winnow adds
  the crack in this:** the Authority is not the top. In the Spire's first district its own wardens
  take the quota from a sealed channel above them and are afraid of it. The Authority is a *hand* —
  something above it writes the number, decides how choosy the wire gets, and eats what the throat
  sends up. Who/what that is remains unrevealed (see the next-district hooks below).

---

## Hooks into the Spire (the continuity contract)

The Spire is the next area. Whatever it becomes, it **must** honor these, or it retcons the Bloom:

1. **It attaches at the Bloom Uptake.** `bloom_uptake` carries a deliberately dangling up-seam (no
   traversable exit yet), mirroring how the Windlass Anchor Gate dangled up into the Bloom. The Spire
   wires in there.

2. **Ascent is a harvest; the ascended become ghosts in the Latticework.** This is canon now
   (committed in content and the Lexicon). The Spire is where they went. It can reveal the mechanism,
   the scale, and the purpose — but not that it *isn't* happening.

3. **Two entry states — handle both.** The Bloom finale forks, and each sets flags the Spire must read:
   - **Ascend** → `bloom_ascended`. The player took the door — i.e. walked into the harvest. This was
     framed as an ominous soft-terminus. If the Spire lets an ascended player continue, it has to
     reckon with what "you are now substrate" means for a playable character (a hard, interesting
     design problem — resolve it deliberately).
   - **Expose** → `bloom_throat_starved` + `bloom_season_cascade` (+ an Authority heat spike). The
     player refused the door, broke the Bloom's harvest, and stayed in the world marked as the one who
     did it. `bloom_throat_starved` forces the Bloom's `draw` to `slack` permanently.
   - Also `bloom_truth_substrate` (from the Uptake ICE) marks that the player *knows* the truth,
     regardless of which ending they chose.

4. **The gloss / the shunt.** The neural shunt fitted at the Bloom's Gloss parlor is the harvest
   interface — what makes a person Latticework-ready. It's currently modeled on a `bloom_glossed`
   knowledge flag because no Chrome & Meat body-state system exists yet. When that system is built,
   `bloom_gloss.exs` is the anchor to wire real augments into, and the Spire is the natural place the
   shunt "completes."

5. **Tone shift is allowed; the reveal is not negotiable.** The Bloom's register is salvaged opulence
   with pockets of rot. The Spire can be anything above that — but keep the Authority as the
   throughline power, keep the salvaged-future voice (Constitution + Style Guide still win), and don't
   soften or reverse the harvest.

The Winnow (the Spire's first district) honors all five of the above. It reads both Bloom entry
states, cracks the echo-cover further (ascended → substrate → *still awake* substrate), and completes
the shunt at its Vestibule per hook #4.

## Hooks into the next Spire district (what the Winnow set)

The Winnow is now built, and it establishes things the *next* Spire district must not contradict:

1. **The Authority answers to something above it.** Confirmed, not just implied: the Winnow's wardens
   receive the quota from a sealed channel above them. What that tier *is* is deliberately unrevealed —
   the next district's biggest design space. Don't retcon it back to "the Authority is the top."

2. **The Winnow's Head-End dangles the next up-seam.** `winnow_head_end` carries a deliberately
   dangling up-seam (no traversable exit yet), mirroring `bloom_uptake`. The next district wires in
   there. The player reaches it via `winnow_shunt_complete` (the Vestibule ICE).

3. **`winnow_ascended` is the forward flag.** The Winnow finale (`winnow_ascension_glimpse`) grants it:
   the player has seen the Spire for what it is (a gut, not a summit) and looked the tier-above in the
   eye without being swallowed. There is **no ascend/expose-style fork** here — the Winnow is an opener,
   not a stratum finale; every path converges on this glimpse. The next district reads `winnow_ascended`.

4. **The servant caste + the twin facts.** Kept-whole ascended staff the machine as a labor caste
   (`quota` = the Authority's demand, Bloom-fed; `waking` = how lucid the caste is, player-fed). The
   Bloom's ending drives the opening state: **Expose** (`bloom_throat_starved`) → `quota` starts at
   `culling`; **Ascend** (`bloom_ascended`) → `pressing`. `winnow_caste_lucid` marks the caste turned.
   If the next district revisits the Winnow or its people, honor these.

5. **Something survives the wire, and it's awake.** Via Tithe (half-culled, lucid): an ascended mind
   isn't gone, it's *used*, and a remainder of it still knows and wants out. This partially answers the
   old open question and constrains what "substrate" means — it is not inert storage.

### Open questions the next district gets to answer

Left deliberately open — design space, not contradictions:
- **What is the tier above the Authority?** (The Winnow proved it exists; it has no face yet.)
- What does it *want* the substrate for — computation, control, something else?
- Are *all* ghosts in the Latticework ascended people, or only some? Is Ghostwork itself implicated?
- Can the awake remainder of an ascended mind (Tithe, and the ones above) be reached, freed, or become
  something? How much is left, and for how long?

---

*Last updated when the Winnow shipped (the Spire's first district). Extend this doc whenever an area
reveals something the next one must not contradict.*
