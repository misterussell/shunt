# Shunt Project Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up a working Phoenix 1.8 LiveView app named `shunt` in this directory, backed by a Dockerized Postgres dev database, with the toolchain (mix/Elixir) running locally.

**Architecture:** Use the standard `phx.new` generator to scaffold the app in place (current directory). Add a single-service `docker-compose.yml` that runs only Postgres; the Phoenix app itself runs via the host's local Elixir/Mix install. No application code, schemas, or auth are added — this plan only produces a runnable, empty Phoenix app talking to a Dockerized database.

**Tech Stack:** Elixir 1.19.5 / OTP 28 (already installed locally), Phoenix 1.8.1 (LiveView default), Ecto + Postgrex, Postgres 16 (Docker), Docker Compose v5.

## Global Constraints

- App name: `shunt` (OTP app `:shunt`, module prefix `Shunt`) — per spec `docs/superpowers/specs/2026-06-21-project-scaffold-design.md`.
- Generate with all Phoenix generator defaults kept (LiveView, Ecto/Postgres, Swoosh mailer, gettext, LiveDashboard, esbuild/Tailwind) — no `--no-*` flags.
- No auth (`phx.gen.auth`) in this plan — deferred per spec.
- Postgres runs in Docker; Phoenix/mix run locally on the host — per spec, rejected full containerization for this solo-dev project.
- `config/dev.exs` must not need hostname changes — generator default `hostname: "localhost"` is relied upon, so the Postgres container must publish port `5432` to the host.

---

### Task 1: Generate the Phoenix LiveView app scaffold

**Files:**
- Create: entire Phoenix project tree (`mix.exs`, `lib/`, `config/`, `assets/`, `test/`, `priv/`, `.gitignore`, `.formatter.exs`, `AGENTS.md`, `README.md`) via the `phx.new` generator.
- Existing (untouched): `docs/superpowers/` (specs and plans), `.git/`.

**Interfaces:**
- Produces: OTP app `:shunt`, module prefix `Shunt`, generated `mix.exs` deps (`phoenix ~> 1.8.1`, `phoenix_live_view ~> 1.1.0`, `ecto_sql`, `postgrex`, etc.), `config/dev.exs` with `Shunt.Repo` configured for `username: "postgres"`, `password: "postgres"`, `hostname: "localhost"`, `database: "shunt_dev"`.
- Later tasks consume: the `docker-compose.yml` in Task 2 must match these exact `Shunt.Repo` credentials/database name from the generated `config/dev.exs`.

- [ ] **Step 1: Run the Phoenix generator**

```bash
mix phx.new . --app shunt --install
```

This generates into the current directory (already git-initialized, containing only `docs/`). Accept all defaults — do not pass any `--no-*` flags. The `--install` flag runs `mix deps.get`, `mix assets.setup`, and `mix deps.compile` automatically.

- [ ] **Step 2: Verify it compiles cleanly**

```bash
mix compile --warnings-as-errors
```

Expected: `Compiling N files (.ex)` then `Generated shunt app` with no warnings or errors. (No database connection is required to compile.)

- [ ] **Step 3: Confirm the generated `Shunt.Repo` config matches expectations**

```bash
grep -A6 "config :shunt, Shunt.Repo" config/dev.exs
```

Expected output includes `username: "postgres"`, `password: "postgres"`, `hostname: "localhost"`, `database: "shunt_dev"`. If any of these differ from what's shown here (generator defaults can change between Phoenix versions), note the actual values — Task 2's `docker-compose.yml` must use the actual values, not these assumed ones.

- [ ] **Step 4: Commit the generated scaffold**

```bash
git add -A
git commit -m "Generate Phoenix LiveView app scaffold via phx.new"
```

---

### Task 2: Add Dockerized Postgres for local development

**Files:**
- Create: `docker-compose.yml` (project root)
- Create: `.dockerignore` (project root) — not used by compose directly here (no app image is built), but documents intent and prevents accidental future `docker build` from picking up `_build`/`deps`.

**Interfaces:**
- Consumes: the exact `username`/`password`/`database` values confirmed in Task 1, Step 3 (this plan assumes the unmodified generator defaults `postgres`/`postgres`/`shunt_dev` — adjust the compose file below if Task 1 found different values).
- Produces: a `db` Postgres service reachable at `localhost:5432` from the host, matching `config/dev.exs`.

- [ ] **Step 1: Write `docker-compose.yml`**

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: shunt_dev
    ports:
      - "5432:5432"
    volumes:
      - shunt_postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  shunt_postgres_data:
```

- [ ] **Step 2: Write `.dockerignore`**

```
_build/
deps/
.git/
.elixir_ls/
node_modules/
```

- [ ] **Step 3: Validate the compose file**

```bash
docker compose config
```

Expected: prints the parsed, fully-resolved compose config with no errors (no YAML/schema errors).

- [ ] **Step 4: Start Postgres and confirm it's healthy**

```bash
docker compose up -d
docker compose ps
```

Expected: `docker compose ps` shows the `db` service with status `running (healthy)` (may take a few seconds — re-run `docker compose ps` if it still shows `starting`).

- [ ] **Step 5: Confirm Postgres is reachable on the published port**

```bash
docker compose exec db pg_isready -U postgres
```

Expected: `/var/run/postgresql:5432 - accepting connections`

- [ ] **Step 6: Commit**

```bash
git add docker-compose.yml .dockerignore
git commit -m "Add docker-compose for local Postgres dev database"
```

---

### Task 3: Wire up the database and verify the full app boots

**Files:**
- Modify: none (verification-only task; no new files expected).

**Interfaces:**
- Consumes: `Shunt.Repo` config from Task 1, running Postgres container from Task 2.
- Produces: a running `shunt_dev` database with Ecto's schema-migrations table, and a confirmed-booting Phoenix server — the foundation all future feature work builds on.

- [ ] **Step 1: Create the dev database**

```bash
mix ecto.create
```

Expected: `The database for Shunt.Repo has been created`

- [ ] **Step 2: Run migrations (none exist yet, but this confirms Ecto can connect and create its migrations table)**

```bash
mix ecto.migrate
```

Expected: exits with no errors (no migrations to run yet, so minimal/no output is normal).

- [ ] **Step 3: Run the generated test suite**

```bash
mix test
```

Expected: all tests pass, e.g. `N tests, 0 failures` (the generated `error_html_test.exs`, `error_json_test.exs`, and `page_controller_test.exs` from `phx.new`).

- [ ] **Step 4: Boot the server and smoke-test it**

```bash
mix phx.server &
sleep 3
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:4000/
kill %1
```

Expected: prints `200`.

- [ ] **Step 5: No commit needed**

This task only verifies behavior against already-committed code; if any step fails, fix the root cause (e.g., a config mismatch between Task 1 and Task 2) and re-run from Step 1, committing the fix to whichever file changed.

---

## Done Criteria

- `mix phx.server` boots successfully against a Dockerized Postgres database.
- `mix test` passes.
- `docker compose up -d` is the only step needed to provide the dev database; no local Postgres install required.
- All scaffold and compose files are committed to git.
