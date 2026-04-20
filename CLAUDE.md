# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Docker-based GitHub Action that wraps the `pumascan` CLI (Puma Scan Professional — a .NET C# security code analyzer). The action is consumed by downstream repos via `uses: pumasecurity/puma-scan-pro-action@v1`.

## Architecture

Three files drive the entire action; changes almost always touch one or more of them together:

- `action.yml` — declares inputs and wires them as **positional** args (`$1..$8`) into the container entrypoint. Input order here MUST match the `READ INPUT VARS` block in `src/entrypoint.sh`. Adding/removing/reordering an input requires updating both files and the README input table.
- `Dockerfile` — `FROM ghcr.io/pumasecurity/puma-scan-pro:<version>-net10-linux-x64`. The base image ships the `pumascan` binary and .NET runtime; this repo only adds `jq` and the entrypoint script. Bumping Puma Scan Pro = bumping this tag.
- `src/entrypoint.sh` — runs inside the container at action execution. Sequence: (1) `dotnet restore` each project in `PUMA_PROJECT_PATHS`, (2) exchange `ACTIONS_ID_TOKEN_REQUEST_TOKEN` for a `PUMA_AUTH_TOKEN` via the GitHub OIDC endpoint with audience `https://portal.pumascan.com`, (3) build and exec `pumascan scan` with optional flags.

### Non-obvious behaviors

- **`"null"` is the sentinel for "unset"**, not empty string. Optional inputs default to the literal string `"null"` in `action.yml`; `entrypoint.sh` checks `if [[ "$VAR" != "null" ]]` before appending the flag. Don't change one side without the other.
- **OIDC is mandatory for license activation.** Consumers must grant `id-token: write` permission, or the token request fails silently (curl returns empty, `pumascan` fails to activate). The `PUMA_LICENSE` secret alone is not sufficient.
- **`dotnet restore` runs on the host-checked-out files**, which means the consuming workflow must run `actions/checkout` first. Missing project files cause a hard exit before `pumascan` is invoked.
- **Project paths are comma-delimited** in a single input string, split via bash word-splitting (`${PUMA_PROJECT_PATHS//,/ }`). Paths containing spaces are not supported.

## Release flow

Tagged releases (`v1`, `v1.6.1`, etc.) are what consumers pin to. A release typically means: bump `FROM` tag in `Dockerfile` to match a new Puma Scan Pro version, then tag. There is no build/test step in this repo — the action *is* the Dockerfile + script.

## Local validation

No test suite. Before committing changes to `entrypoint.sh` or workflow wiring:

- `shellcheck src/entrypoint.sh && shfmt -d src/entrypoint.sh`
- `actionlint action.yml`
- `zizmor .` (workflow security audit; relevant if `.github/workflows/` is added)
- Optional smoke test: `docker build -t puma-action-local . && docker run --rm -e PUMA_LICENSE=... puma-action-local <args>` — note OIDC token exchange will fail outside a GitHub runner, so only the pre-token path is exercisable locally.
