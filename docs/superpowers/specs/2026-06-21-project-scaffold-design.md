# Shunt — Project Scaffold Design

Date: 2026-06-21

## Context

Shunt is a planned cyberpunk-themed incremental crafting game. This spec
covers only the initial setup step: getting a working Phoenix LiveView
project in place with a Dockerized Postgres dev database. Game-specific
design (crafting mechanics, idle/tick loop, theming, player accounts) is
out of scope and will be brainstormed separately once this foundation
exists.

## Goals

- A freshly generated Phoenix 1.8 LiveView app, buildable and runnable
  with `mix phx.server`.
- Postgres available for local development without installing it on the
  host machine.
- Fast solo-developer iteration: standard `mix`/editor/LSP workflow,
  Postgres as the only containerized piece.

## Non-goals

- Authentication (`phx.gen.auth`) — deferred until the player/save-state
  model is designed.
- Any game logic, schemas, or UI theming.
- Full containerization of the app itself (rejected — see Decisions).

## Decisions

1. **App generation**: `mix phx.new . --app shunt --live` run directly in
   this directory (already empty, already named `Shunt`). Produces OTP
   app `shunt`, module prefix `Shunt`.
2. **Generator defaults kept as-is**: Ecto + Postgres, Swoosh mailer,
   gettext, LiveDashboard, esbuild/Tailwind asset pipeline. No flags
   disabled.
3. **Postgres runs in Docker; the app runs locally via `mix`.**
   Considered fully containerizing the app as well (Dockerfile + compose
   service for the app), but rejected for this solo-developer project:
   the host already has Elixir 1.19.5/OTP 28 installed, so running `mix`
   locally keeps editor/LSP support and recompile speed, and there's no
   need for environment parity across machines or developers right now.
4. **`docker-compose.yml`** at the project root with one service:
   - `db`: `postgres:16-alpine`
   - named volume for data persistence
   - healthcheck
   - port `5432` published to the host
5. **No config changes needed**: `config/dev.exs` already defaults to
   `hostname: "localhost"`, which works since the container's Postgres
   port is published to the host.

## Workflow

```
docker compose up -d      # start Postgres
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server
```

## Out of scope (future brainstorming)

- Game loop / tick mechanism (likely a GenServer or Oban-based scheduler).
- Cyberpunk Tailwind theme.
- `phx.gen.auth` once the player/save-state model is designed.
- Possible future multiplayer/shared-world architecture (PubSub,
  Presence) — flagged as a possibility, not committed to.
