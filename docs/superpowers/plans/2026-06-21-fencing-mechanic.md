# Fencing Mechanic Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder "Do a Job" action with the real buy-low/sell-high fencing loop: find a lead, decide to take it or pass, then sell a held item to a buyer — with Heat and Cred as real consequences, and every offer/sale grounded in Kaspav's setting.

**Architecture:** A new `Shunt.Fencing` context (mirroring the existing `Shunt.Players` context style: plain functions taking/returning a `%Player{}`) backed by a static `Shunt.Fencing.Catalog` module (plain data, not Ecto-backed). Two new nullable string columns on `players` (`current_offer_key`, `held_item_key`) track the player's position in a three-state loop (idle → offer pending → holding → idle). `ShuntWeb.DashboardLive` renders one of the three states and wires up the four new actions.

**Tech Stack:** Elixir, Phoenix LiveView, Ecto, Postgres (existing app stack — no new dependencies).

## Global Constraints

- Singleton/lazy-ensure-one-exists patterns are forbidden in this codebase (see `CLAUDE.md`). The single player row is already seeded explicitly; nothing in this plan introduces new singleton logic.
- Don't use `String.to_atom/1` on any value — catalog item keys are plain strings end-to-end, never converted to atoms.
- `Ecto.Changeset.get_field/2` for changesets, direct struct field access (`player.field`) for plain structs — never map-access syntax on structs.
- Match existing code style exactly: context functions take/return `%Player{}` structs, use `Ecto.Changeset.change/2` + `Repo.update/1` for programmatic field updates (not user-submitted form changesets), and clamp Heat to `[0, 100]` via a private `clamp_heat/1` helper.
- Full spec: `docs/superpowers/specs/2026-06-21-fencing-mechanic-design.md`. Re-read it if a task here seems ambiguous — this plan is the authoritative breakdown of that spec, but the spec has the full catalog rationale and non-goals.

---

### Task 1: Migration + Player schema fields

**Files:**
- Create: `priv/repo/migrations/<timestamp>_add_fencing_fields_to_players.exs`
- Modify: `lib/shunt/players/player.ex`
- Modify: `test/shunt/players_test.exs`

**Interfaces:**
- Produces: `%Shunt.Players.Player{}` struct now has `:current_offer_key` (string or nil) and `:held_item_key` (string or nil) fields, both defaulting to `nil`. All later tasks read/write these two fields directly on the struct.

- [ ] **Step 1: Write the failing test**

Add this test to the `"create_player!/0"` describe block in `test/shunt/players_test.exs`:

```elixir
    test "creates a player with no offer or held item" do
      player = Players.create_player!()

      assert player.current_offer_key == nil
      assert player.held_item_key == nil
    end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/players_test.exs`
Expected: FAIL (compile error — `key :current_offer_key not found in: %Shunt.Players.Player{}`)

- [ ] **Step 3: Generate and write the migration**

Run: `mix ecto.gen.migration add_fencing_fields_to_players`

This creates `priv/repo/migrations/<timestamp>_add_fencing_fields_to_players.exs`. Replace its contents with:

```elixir
defmodule Shunt.Repo.Migrations.AddFencingFieldsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :current_offer_key, :string
      add :held_item_key, :string
    end
  end
end
```

- [ ] **Step 4: Run the migration**

Run: `mix ecto.migrate`
Expected: output shows the new migration applied successfully.

- [ ] **Step 5: Add the fields to the schema**

In `lib/shunt/players/player.ex`, add two lines inside the `schema "players" do ... end` block, after the existing `:heat` field:

```elixir
    field :current_offer_key, :string
    field :held_item_key, :string
```

- [ ] **Step 6: Run test to verify it passes**

Run: `mix test test/shunt/players_test.exs`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add priv/repo/migrations lib/shunt/players/player.ex test/shunt/players_test.exs
git commit -m "Add current_offer_key and held_item_key fields to Player"
```

---

### Task 2: Fencing.Catalog module

**Files:**
- Create: `lib/shunt/fencing/catalog.ex`
- Test: `test/shunt/fencing/catalog_test.exs`

**Interfaces:**
- Consumes: nothing (no dependency on other tasks).
- Produces: `Shunt.Fencing.Catalog.items/0 -> [item_map]` and `Shunt.Fencing.Catalog.fetch!/1 -> item_map` (raises if key unknown). Every `item_map` has keys `:key` (string), `:name` (string), `:tier` (`:clean | :warm | :hot`), `:buy_cost` (integer), `:sell_value` (integer), `:heat_cost` (integer), `:cred_gain` (integer), `:offer_text` (string), `:sell_text` (string). All later tasks call `Catalog.items/0` and `Catalog.fetch!/1`.

- [ ] **Step 1: Write the failing test**

Create `test/shunt/fencing/catalog_test.exs`:

```elixir
defmodule Shunt.Fencing.CatalogTest do
  use ExUnit.Case, async: true

  alias Shunt.Fencing.Catalog

  describe "items/0" do
    test "returns six items spanning clean, warm, and hot tiers" do
      items = Catalog.items()

      assert length(items) == 6
      assert Enum.count(items, &(&1.tier == :clean)) == 2
      assert Enum.count(items, &(&1.tier == :warm)) == 2
      assert Enum.count(items, &(&1.tier == :hot)) == 2
    end

    test "every item has a unique key and a positive margin" do
      items = Catalog.items()
      keys = Enum.map(items, & &1.key)

      assert length(Enum.uniq(keys)) == length(keys)
      assert Enum.all?(items, &(&1.sell_value > &1.buy_cost))
    end
  end

  describe "fetch!/1" do
    test "returns the item matching the given key" do
      item = Catalog.fetch!("scrap_dermal_plating")

      assert item.name == "Scrap Dermal Plating"
    end

    test "raises when the key is not in the catalog" do
      assert_raise RuntimeError, ~r/unknown catalog item key/, fn ->
        Catalog.fetch!("not_a_real_key")
      end
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/fencing/catalog_test.exs`
Expected: FAIL (`Shunt.Fencing.Catalog` module not available/undefined function)

- [ ] **Step 3: Write the catalog module**

Create `lib/shunt/fencing/catalog.ex`:

```elixir
defmodule Shunt.Fencing.Catalog do
  @items [
    %{
      key: "scrap_dermal_plating",
      name: "Scrap Dermal Plating",
      tier: :clean,
      buy_cost: 10,
      sell_value: 18,
      heat_cost: 5,
      cred_gain: 1,
      offer_text:
        "A ganger's leftovers — dented plating still tacky with someone else's blood.",
      sell_text: "A patcher in a stall off the main concourse barely looks up before paying."
    },
    %{
      key: "bootleg_credchip_stack",
      name: "Bootleg Credchip Stack",
      tier: :clean,
      buy_cost: 15,
      sell_value: 25,
      heat_cost: 6,
      cred_gain: 1,
      offer_text: "Counterfeit chips, good enough to fool a distracted register — for a while.",
      sell_text: "A till-runner takes the stack without counting it twice."
    },
    %{
      key: "grey_market_neural_patch",
      name: "Grey-Market Neural Patch",
      tier: :warm,
      buy_cost: 25,
      sell_value: 45,
      heat_cost: 12,
      cred_gain: 2,
      offer_text: "An unlicensed reflex patch, still warm from whoever wore it last.",
      sell_text: "A Graftsman's apprentice pays cash, no questions, no receipt."
    },
    %{
      key: "cracked_latticework_relay_key",
      name: "Cracked Latticework Relay Key",
      tier: :warm,
      buy_cost: 30,
      sell_value: 55,
      heat_cost: 15,
      cred_gain: 3,
      offer_text:
        "A stolen access token. Somewhere uptown, it's still pinging for a body that isn't yours.",
      sell_text: "A Latticework Collective courier pays fast and leaves faster."
    },
    %{
      key: "stolen_corp_biomod_prototype",
      name: "Stolen Corp Biomod Prototype",
      tier: :hot,
      buy_cost: 55,
      sell_value: 110,
      heat_cost: 28,
      cred_gain: 4,
      offer_text:
        "Sealed casing, corp serials filed off. Whoever lost this is already looking for it.",
      sell_text:
        "A Chrome & Meat broker doesn't ask where it came from — just whether it's clean."
    },
    %{
      key: "burned_netrunners_memory_core",
      name: "Burned Netrunner's Memory Core",
      tier: :hot,
      buy_cost: 65,
      sell_value: 130,
      heat_cost: 32,
      cred_gain: 5,
      offer_text:
        "Salvaged off a netrunner who flatlined mid-run. Still humming with whatever fried them.",
      sell_text: "A Fleshless acolyte trades scrip for it like it's a relic."
    }
  ]

  def items, do: @items

  def fetch!(key) do
    Enum.find(@items, &(&1.key == key)) ||
      raise "unknown catalog item key: #{inspect(key)}"
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt/fencing/catalog_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt/fencing/catalog.ex test/shunt/fencing/catalog_test.exs
git commit -m "Add Fencing.Catalog with six world-flavored goods"
```

---

### Task 3: Fencing.find_lead/1

**Files:**
- Create: `lib/shunt/fencing.ex`
- Create: `test/shunt/fencing_test.exs`

**Interfaces:**
- Consumes: `Shunt.Fencing.Catalog.items/0` (Task 2), `%Shunt.Players.Player{}` with `:current_offer_key`/`:held_item_key` (Task 1).
- Produces: `Shunt.Fencing.find_lead(%Player{}) -> {:ok, %Player{}} | {:error, :offer_in_progress}`. Later tasks add more functions to this same module/file.

- [ ] **Step 1: Write the failing test**

Create `test/shunt/fencing_test.exs`:

```elixir
defmodule Shunt.FencingTest do
  use Shunt.DataCase

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players

  describe "find_lead/1" do
    test "sets current_offer_key to a valid catalog key when idle" do
      player = Players.create_player!()

      assert {:ok, updated} = Fencing.find_lead(player)

      valid_keys = Enum.map(Catalog.items(), & &1.key)
      assert updated.current_offer_key in valid_keys
    end

    test "returns an error when an offer is already pending" do
      player = Players.create_player!()
      {:ok, player} = Fencing.find_lead(player)

      assert Fencing.find_lead(player) == {:error, :offer_in_progress}
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/fencing_test.exs`
Expected: FAIL (`Shunt.Fencing` module not available/undefined function)

- [ ] **Step 3: Write the minimal implementation**

Create `lib/shunt/fencing.ex`:

```elixir
defmodule Shunt.Fencing do
  alias Shunt.Repo
  alias Shunt.Players.Player
  alias Shunt.Fencing.Catalog

  def find_lead(%Player{current_offer_key: nil, held_item_key: nil} = player) do
    item = Enum.random(Catalog.items())

    player
    |> Ecto.Changeset.change(%{current_offer_key: item.key})
    |> Repo.update()
  end

  def find_lead(%Player{}), do: {:error, :offer_in_progress}
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt/fencing_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt/fencing.ex test/shunt/fencing_test.exs
git commit -m "Add Fencing.find_lead/1"
```

---

### Task 4: Fencing.take_offer/1

**Files:**
- Modify: `lib/shunt/fencing.ex`
- Modify: `test/shunt/fencing_test.exs`

**Interfaces:**
- Consumes: `Catalog.fetch!/1` (Task 2).
- Produces: `Shunt.Fencing.take_offer(%Player{}) -> {:ok, %Player{}} | {:error, :insufficient_scrip} | {:error, :no_offer}`.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt/fencing_test.exs`, after the `find_lead/1` describe block:

```elixir
  describe "take_offer/1" do
    test "deducts buy_cost from scrip and moves the offer to held_item_key" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{scrip: 100, current_offer_key: item.key})
        |> Repo.update()

      assert {:ok, updated} = Fencing.take_offer(player)

      assert updated.scrip == 100 - item.buy_cost
      assert updated.held_item_key == item.key
      assert updated.current_offer_key == nil
    end

    test "returns an error when there is no pending offer" do
      player = Players.create_player!()

      assert Fencing.take_offer(player) == {:error, :no_offer}
    end

    test "returns an error when scrip is insufficient" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{scrip: 0, current_offer_key: item.key})
        |> Repo.update()

      assert Fencing.take_offer(player) == {:error, :insufficient_scrip}
    end
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/fencing_test.exs`
Expected: FAIL (`Fencing.take_offer/1 is undefined`)

- [ ] **Step 3: Write the minimal implementation**

Add to `lib/shunt/fencing.ex`, after `find_lead/1`:

```elixir
  def take_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def take_offer(%Player{current_offer_key: key, scrip: scrip} = player) do
    item = Catalog.fetch!(key)

    if scrip < item.buy_cost do
      {:error, :insufficient_scrip}
    else
      player
      |> Ecto.Changeset.change(%{
        scrip: scrip - item.buy_cost,
        current_offer_key: nil,
        held_item_key: key
      })
      |> Repo.update()
    end
  end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt/fencing_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt/fencing.ex test/shunt/fencing_test.exs
git commit -m "Add Fencing.take_offer/1"
```

---

### Task 5: Fencing.pass_offer/1

**Files:**
- Modify: `lib/shunt/fencing.ex`
- Modify: `test/shunt/fencing_test.exs`

**Interfaces:**
- Produces: `Shunt.Fencing.pass_offer(%Player{}) -> {:ok, %Player{}} | {:error, :no_offer}`.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt/fencing_test.exs`, after the `take_offer/1` describe block:

```elixir
  describe "pass_offer/1" do
    test "clears the pending offer" do
      player = Players.create_player!()
      {:ok, player} = Fencing.find_lead(player)

      assert {:ok, updated} = Fencing.pass_offer(player)

      assert updated.current_offer_key == nil
    end

    test "returns an error when there is no pending offer" do
      player = Players.create_player!()

      assert Fencing.pass_offer(player) == {:error, :no_offer}
    end
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/fencing_test.exs`
Expected: FAIL (`Fencing.pass_offer/1 is undefined`)

- [ ] **Step 3: Write the minimal implementation**

Add to `lib/shunt/fencing.ex`, after `take_offer/1`:

```elixir
  def pass_offer(%Player{current_offer_key: nil}), do: {:error, :no_offer}

  def pass_offer(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{current_offer_key: nil})
    |> Repo.update()
  end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt/fencing_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt/fencing.ex test/shunt/fencing_test.exs
git commit -m "Add Fencing.pass_offer/1"
```

---

### Task 6: Fencing.sell_held_item/1

**Files:**
- Modify: `lib/shunt/fencing.ex`
- Modify: `test/shunt/fencing_test.exs`

**Interfaces:**
- Produces: `Shunt.Fencing.sell_held_item(%Player{}) -> {:ok, %Player{}} | {:error, :no_held_item}`. This is the last `Shunt.Fencing` function the LiveView tasks depend on.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt/fencing_test.exs`, after the `pass_offer/1` describe block:

```elixir
  describe "sell_held_item/1" do
    test "adds sell_value, cred_gain, and heat_cost, then clears held_item_key" do
      player = Players.create_player!()
      item = Catalog.fetch!("cracked_latticework_relay_key")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key})
        |> Repo.update()

      assert {:ok, updated} = Fencing.sell_held_item(player)

      assert updated.scrip == player.scrip + item.sell_value
      assert updated.cred == player.cred + item.cred_gain
      assert updated.heat == player.heat + item.heat_cost
      assert updated.held_item_key == nil
    end

    test "clamps heat at 100" do
      player = Players.create_player!()
      item = Catalog.fetch!("burned_netrunners_memory_core")

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{held_item_key: item.key, heat: 90})
        |> Repo.update()

      assert {:ok, updated} = Fencing.sell_held_item(player)

      assert updated.heat == 100
    end

    test "returns an error when there is no held item" do
      player = Players.create_player!()

      assert Fencing.sell_held_item(player) == {:error, :no_held_item}
    end
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt/fencing_test.exs`
Expected: FAIL (`Fencing.sell_held_item/1 is undefined`)

- [ ] **Step 3: Write the minimal implementation**

Add to `lib/shunt/fencing.ex`, after `pass_offer/1`:

```elixir
  def sell_held_item(%Player{held_item_key: nil}), do: {:error, :no_held_item}

  def sell_held_item(%Player{held_item_key: key} = player) do
    item = Catalog.fetch!(key)

    player
    |> Ecto.Changeset.change(%{
      scrip: player.scrip + item.sell_value,
      cred: player.cred + item.cred_gain,
      heat: clamp_heat(player.heat + item.heat_cost),
      held_item_key: nil
    })
    |> Repo.update()
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt/fencing_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt/fencing.ex test/shunt/fencing_test.exs
git commit -m "Add Fencing.sell_held_item/1"
```

---

### Task 7: Remove "Do a Job"

**Files:**
- Modify: `lib/shunt/players.ex`
- Modify: `lib/shunt_web/live/dashboard_live.ex`
- Modify: `test/shunt/players_test.exs`
- Modify: `test/shunt_web/live/dashboard_live_test.exs`

**Interfaces:**
- Consumes: nothing new.
- Produces: `Shunt.Players` no longer exports `do_job/1`. `ShuntWeb.DashboardLive` no longer has a `#do-job-button` or a `"do_job"` event clause. This must land before Task 8, since Task 8 adds the replacement UI in the same render function.

- [ ] **Step 1: Remove do_job from Shunt.Players**

In `lib/shunt/players.ex`, delete the `@job_scrip_gain`, `@job_cred_gain`, `@job_heat_gain` module attributes and the entire `do_job/1` function. The file should read:

```elixir
defmodule Shunt.Players do
  alias Shunt.Repo
  alias Shunt.Players.Player

  @lay_low_cred_cost 10
  @lay_low_heat_reduction 20

  def create_player! do
    Repo.insert!(%Player{})
  end

  def get_player! do
    Repo.one!(Player)
  end

  def lay_low(%Player{cred: cred}) when cred < @lay_low_cred_cost do
    {:error, :insufficient_cred}
  end

  def lay_low(%Player{} = player) do
    player
    |> Ecto.Changeset.change(%{
      cred: max(player.cred - @lay_low_cred_cost, 0),
      heat: clamp_heat(player.heat - @lay_low_heat_reduction)
    })
    |> Repo.update()
  end

  defp clamp_heat(heat), do: heat |> max(0) |> min(100)
end
```

- [ ] **Step 2: Remove the do_job test and fix lay_low's setup**

In `test/shunt/players_test.exs`, delete the entire `describe "do_job/1" do ... end` block. Then replace the `describe "lay_low/1" do ... end` block (which currently calls `Players.do_job/1` twice to set up cred/heat) with:

```elixir
  describe "lay_low/1" do
    test "decreases cred and heat" do
      player = Players.create_player!()

      {:ok, player} =
        player
        |> Ecto.Changeset.change(%{cred: 30, heat: 40})
        |> Repo.update()

      assert {:ok, updated} = Players.lay_low(player)

      assert updated.cred == player.cred - 10
      assert updated.heat == player.heat - 20
    end
  end
```

- [ ] **Step 3: Remove do_job from the dashboard LiveView**

In `lib/shunt_web/live/dashboard_live.ex`, delete the `handle_event("do_job", ...)` clause and the `#do-job-button` button. The file should read:

```elixir
defmodule ShuntWeb.DashboardLive do
  use ShuntWeb, :live_view

  alias Shunt.Players

  def mount(_params, _session, socket) do
    {:ok, assign(socket, player: Players.get_player!())}
  end

  def handle_event("lay_low", _params, socket) do
    case Players.lay_low(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign(socket, player: player)}
      {:error, :insufficient_cred} -> {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <div class="border border-gray-300 rounded-lg p-4 space-y-2">
          <p id="resource-cred">Cred: {@player.cred}</p>
          <p id="resource-scrip">Scrip: {@player.scrip}</p>
          <div id="resource-heat">
            <p>Heat: {@player.heat}/100</p>
            <div class="w-full h-2 bg-gray-200 rounded">
              <div class="h-2 bg-red-500 rounded" style={"width: #{@player.heat}%"}></div>
            </div>
          </div>
        </div>

        <div class="flex gap-4">
          <button
            id="lay-low-button"
            phx-click="lay_low"
            class="px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={@player.cred < 10}
          >
            Lay Low
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
```

- [ ] **Step 4: Remove the do_job test and fix lay_low's setup in the LiveView test**

Replace `test/shunt_web/live/dashboard_live_test.exs` entirely with:

```elixir
defmodule ShuntWeb.DashboardLiveTest do
  use ShuntWeb.ConnCase

  import Phoenix.LiveViewTest

  setup do
    Shunt.Players.create_player!()
    :ok
  end

  test "renders initial resource values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#resource-cred", "Cred: 0")
    assert has_element?(view, "#resource-scrip", "Scrip: 0")
    assert has_element?(view, "#resource-heat", "Heat: 0/100")
  end

  test "clicking Lay Low decreases displayed resources", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, cred: 30, heat: 40))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#lay-low-button") |> render_click()

    assert has_element?(view, "#resource-cred", "Cred: 20")
    assert has_element?(view, "#resource-heat", "Heat: 20/100")
  end
end
```

- [ ] **Step 5: Run both test files to verify they pass**

Run: `mix test test/shunt/players_test.exs test/shunt_web/live/dashboard_live_test.exs`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/shunt/players.ex lib/shunt_web/live/dashboard_live.ex test/shunt/players_test.exs test/shunt_web/live/dashboard_live_test.exs
git commit -m "Remove Do a Job placeholder"
```

---

### Task 8: Dashboard — Find a Lead button + offer display

**Files:**
- Modify: `lib/shunt_web/live/dashboard_live.ex`
- Modify: `test/shunt_web/live/dashboard_live_test.exs`

**Interfaces:**
- Consumes: `Shunt.Fencing.find_lead/1` (Task 3), `Shunt.Fencing.Catalog.fetch!/1` (Task 2).
- Produces: socket now carries derived `:offer` and `:held` assigns (item map or `nil`) alongside `:player`, computed by a new private `assign_player/2` helper. Tasks 9 and 10 reuse `assign_player/2` and the `@offer`/`@held` assigns.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt_web/live/dashboard_live_test.exs`, after the existing `"clicking Lay Low..."` test:

```elixir
  test "clicking Find a Lead reveals an offer", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#current-offer")

    view |> element("#find-lead-button") |> render_click()

    assert has_element?(view, "#current-offer")
    refute has_element?(view, "#find-lead-button")
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: FAIL (`#find-lead-button` not found — the button doesn't exist yet)

- [ ] **Step 3: Write the minimal implementation**

Replace `lib/shunt_web/live/dashboard_live.ex` entirely with:

```elixir
defmodule ShuntWeb.DashboardLive do
  use ShuntWeb, :live_view

  alias Shunt.Fencing
  alias Shunt.Fencing.Catalog
  alias Shunt.Players

  def mount(_params, _session, socket) do
    {:ok, assign_player(socket, Players.get_player!())}
  end

  def handle_event("lay_low", _params, socket) do
    case Players.lay_low(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, :insufficient_cred} -> {:noreply, socket}
    end
  end

  def handle_event("find_lead", _params, socket) do
    case Fencing.find_lead(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, :offer_in_progress} -> {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-6">
        <div class="border border-gray-300 rounded-lg p-4 space-y-2">
          <p id="resource-cred">Cred: {@player.cred}</p>
          <p id="resource-scrip">Scrip: {@player.scrip}</p>
          <div id="resource-heat">
            <p>Heat: {@player.heat}/100</p>
            <div class="w-full h-2 bg-gray-200 rounded">
              <div class="h-2 bg-red-500 rounded" style={"width: #{@player.heat}%"}></div>
            </div>
          </div>
        </div>

        <div class="border border-gray-300 rounded-lg p-4 space-y-3">
          <%= cond do %>
            <% @offer == nil and @held == nil -> %>
              <button
                id="find-lead-button"
                phx-click="find_lead"
                class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
              >
                Find a Lead
              </button>
            <% @offer != nil -> %>
              <div id="current-offer" class="space-y-2">
                <p class="font-semibold">{@offer.name}</p>
                <span class={[
                  "inline-block px-2 py-0.5 rounded text-xs",
                  @offer.tier == :clean && "bg-green-100",
                  @offer.tier == :warm && "bg-yellow-100",
                  @offer.tier == :hot && "bg-red-100"
                ]}>
                  {@offer.tier}
                </span>
                <p>{@offer.offer_text}</p>
                <p>Buy: {@offer.buy_cost} Scrip</p>
              </div>
            <% true -> %>
              <div id="held-item" class="space-y-2">
                <p class="font-semibold">{@held.name}</p>
                <p>{@held.sell_text}</p>
                <p>Sell: {@held.sell_value} Scrip · +{@held.heat_cost} Heat</p>
              </div>
          <% end %>
        </div>

        <div class="flex gap-4">
          <button
            id="lay-low-button"
            phx-click="lay_low"
            class="px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
            disabled={@player.cred < 10}
          >
            Lay Low
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp assign_player(socket, player) do
    socket
    |> assign(:player, player)
    |> assign(:offer, catalog_item(player.current_offer_key))
    |> assign(:held, catalog_item(player.held_item_key))
  end

  defp catalog_item(nil), do: nil
  defp catalog_item(key), do: Catalog.fetch!(key)
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt_web/live/dashboard_live.ex test/shunt_web/live/dashboard_live_test.exs
git commit -m "Add Find a Lead button and offer display to dashboard"
```

---

### Task 9: Dashboard — Take It / Pass buttons

**Files:**
- Modify: `lib/shunt_web/live/dashboard_live.ex`
- Modify: `test/shunt_web/live/dashboard_live_test.exs`

**Interfaces:**
- Consumes: `Shunt.Fencing.take_offer/1`, `Shunt.Fencing.pass_offer/1` (Tasks 4, 5), `assign_player/2` (Task 8).
- Produces: `#take-offer-button` and `#pass-offer-button` in the offer-pending state. Task 10 depends on the held-item state this produces.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt_web/live/dashboard_live_test.exs`, after the `"clicking Find a Lead..."` test:

```elixir
  test "taking an offer deducts scrip and shows the held item", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100))

    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()

    assert has_element?(view, "#held-item")
    refute has_element?(view, "#current-offer")
  end

  test "passing an offer returns to idle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#find-lead-button") |> render_click()
    view |> element("#pass-offer-button") |> render_click()

    assert has_element?(view, "#find-lead-button")
    refute has_element?(view, "#current-offer")
  end
```

Note: `scrip: 100` covers every catalog item's `buy_cost` (max 65), so this test passes regardless of which random item `find_lead` picks.

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: FAIL (`#take-offer-button` / `#pass-offer-button` not found)

- [ ] **Step 3: Write the minimal implementation**

In `lib/shunt_web/live/dashboard_live.ex`, add two new `handle_event` clauses after `"find_lead"`:

```elixir
  def handle_event("take_offer", _params, socket) do
    case Fencing.take_offer(socket.assigns.player) do
      {:ok, player} -> {:noreply, assign_player(socket, player)}
      {:error, _reason} -> {:noreply, socket}
    end
  end

  def handle_event("pass_offer", _params, socket) do
    {:ok, player} = Fencing.pass_offer(socket.assigns.player)
    {:noreply, assign_player(socket, player)}
  end
```

Replace the `<% @offer != nil -> %>` branch's div in the template with:

```heex
            <% @offer != nil -> %>
              <div id="current-offer" class="space-y-2">
                <p class="font-semibold">{@offer.name}</p>
                <span class={[
                  "inline-block px-2 py-0.5 rounded text-xs",
                  @offer.tier == :clean && "bg-green-100",
                  @offer.tier == :warm && "bg-yellow-100",
                  @offer.tier == :hot && "bg-red-100"
                ]}>
                  {@offer.tier}
                </span>
                <p>{@offer.offer_text}</p>
                <p>Buy: {@offer.buy_cost} Scrip</p>
                <div class="flex gap-4">
                  <button
                    id="take-offer-button"
                    phx-click="take_offer"
                    class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    disabled={@player.scrip < @offer.buy_cost}
                  >
                    Take It
                  </button>
                  <button
                    id="pass-offer-button"
                    phx-click="pass_offer"
                    class="px-4 py-2 rounded bg-gray-600 text-white hover:bg-gray-700"
                  >
                    Pass
                  </button>
                </div>
              </div>
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/shunt_web/live/dashboard_live.ex test/shunt_web/live/dashboard_live_test.exs
git commit -m "Add Take It and Pass buttons to dashboard"
```

---

### Task 10: Dashboard — Move It button + full happy-path test

**Files:**
- Modify: `lib/shunt_web/live/dashboard_live.ex`
- Modify: `test/shunt_web/live/dashboard_live_test.exs`

**Interfaces:**
- Consumes: `Shunt.Fencing.sell_held_item/1` (Task 6), `assign_player/2` (Task 8).
- Produces: `#sell-item-button`, completing the loop back to idle. No later tasks depend on this — it's the last task in the plan.

- [ ] **Step 1: Write the failing test**

Add to `test/shunt_web/live/dashboard_live_test.exs`, after the `"passing an offer..."` test:

```elixir
  test "find a lead, take it, and sell it updates resources and returns to idle", %{conn: conn} do
    player = Shunt.Players.get_player!()
    Shunt.Repo.update!(Ecto.Changeset.change(player, scrip: 100))

    {:ok, view, _html} = live(conn, ~p"/")

    view |> element("#find-lead-button") |> render_click()
    view |> element("#take-offer-button") |> render_click()
    view |> element("#sell-item-button") |> render_click()

    assert has_element?(view, "#find-lead-button")
    refute has_element?(view, "#held-item")

    player = Shunt.Players.get_player!()
    assert player.scrip > 0
    assert player.cred > 0
    assert player.heat > 0
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: FAIL (`#sell-item-button` not found)

- [ ] **Step 3: Write the minimal implementation**

In `lib/shunt_web/live/dashboard_live.ex`, add a new `handle_event` clause after `"pass_offer"`:

```elixir
  def handle_event("sell_item", _params, socket) do
    {:ok, player} = Fencing.sell_held_item(socket.assigns.player)
    {:noreply, assign_player(socket, player)}
  end
```

Replace the `<% true -> %>` branch's div in the template with:

```heex
            <% true -> %>
              <div id="held-item" class="space-y-2">
                <p class="font-semibold">{@held.name}</p>
                <p>{@held.sell_text}</p>
                <p>Sell: {@held.sell_value} Scrip · +{@held.heat_cost} Heat</p>
                <button
                  id="sell-item-button"
                  phx-click="sell_item"
                  class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700"
                >
                  Move It
                </button>
              </div>
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mix test test/shunt_web/live/dashboard_live_test.exs`
Expected: PASS

- [ ] **Step 5: Run the full test suite and precommit checks**

Run: `mix precommit`
Expected: compiles with no warnings, no unused deps, formatted, all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/shunt_web/live/dashboard_live.ex test/shunt_web/live/dashboard_live_test.exs
git commit -m "Add Move It button, completing the fencing loop"
```
