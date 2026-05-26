# ADR-001: choose lazy.nvim

## Status: accepted

## Date: 2026-04-11

## Context

We need to pick a Neovim plugin manager.
Main candidates: lazy.nvim, packer.nvim, vim-plug

## Decision

Use **lazy.nvim**.

## Rationale

- **lazy-lock.json**: pins exact plugin versions in a file, reproducing the same environment across machines.
- **lazy loading**: lazy-by-default, keeping startup time low.
- **Declarative config**: each plugin lives in its own file (`plugins/*.lua`).
- **Active maintenance**: the de-facto Neovim-community standard as of 2026.
- packer.nvim is no longer maintained.
- vim-plug is not Lua-native.

## Consequences

- Whenever a plugin is added or upgraded, `lazy-lock.json` must be committed alongside the change.
- `checker.enabled = false` disables automatic update checks → updates are explicit (`:Lazy update`).
