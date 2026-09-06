# Repository Guidelines

## Project Goal & Background
This repository is a personal Neovim configuration written from scratch on lazy.nvim, focused on **muscle-memory continuity** with Spacemacs-style workflows.

- Primary goal: make leader and window/navigation keybinds feel close to Spacemacs.
- Secondary goal: keep parity with the approach used in `~/.doom.d` (Doom Emacs), including the pin/deploy workflow.
- When adding or changing bindings, prefer consistency over novelty.

## Project Structure & Module Organization
- `init.lua`: bootstraps lazy.nvim, calls `require("lazy").setup`, then loads the modules below in order.
- `lua/options.lua`, `lua/autocmds.lua`, `lua/commands.lua`, `lua/mappings.lua`: editor options, autocommands, user commands, keymaps. All global keymaps live in `mappings.lua`; buffer-local LSP maps live in `lua/plugins/lsp.lua`.
- `lua/theme.lua`: theme collection discovery (any plugin with a `colors/` dir), persistence, and the Telescope picker.
- `lua/plugins/*.lua`: lazy.nvim specs, one file per concern (`themes`, `ui`, `telescope`, `git`, `lsp`, `completion`, `treesitter`). Plugin config goes in the spec's `opts`/`config`; there is no separate `configs/` directory.
- `after/ftdetect/`: filetype detection overrides.
- `lazy-lock.json`: pinned plugin revisions. Under version control on purpose; see *Plugin Revision Pinning*.
- `bin/nvim-deploy`: moves an installed config onto the lockfile.
- `.stylua.toml`: formatter rules.

## Build, Test, and Development Commands
- `nvim`: start Neovim with this config. Missing plugins install at the locked commits on first start.
- `nvim --headless "+Lazy! restore" +qa`: put installed plugins back onto the lockfile.
- `nvim --headless "+Lazy! update" +qa`: move plugins to upstream and rewrite the lockfile (test machine only).
- `nvim --headless "+checkhealth" +qa`: run Neovim health checks.
- `stylua init.lua lua after`: format all Lua sources.

Run commands from the repository root (`~/.config/nvim`).

## Plugin Revision Pinning
**One machine is the test bed.** Plugin updates are exercised there first, then committed as a lockfile change that other machines deploy, so an untested plugin commit never reaches a machine that is depended on.

- On the test machine: Update freely with `:Lazy update`. It rewrites `lazy-lock.json` in place; commit that diff once the update has proven itself.
- Other machines run `bin/nvim-deploy`, never `:Lazy update`/`:Lazy sync`.
- Never hand-edit `lazy-lock.json`; lazy.nvim owns it.
- Rolling back is `git revert` on the lockfile commit followed by a redeploy.

## Coding Style & Naming Conventions
- Language: Lua. Indentation: 2 spaces, no tabs, max line width 120, no call parentheses on single string/table arguments (`.stylua.toml`).
- lower_snake_case for filenames and Lua module names.
- Every keymap gets a descriptive `desc` (which-key and the command palette rely on it).
- Keep related bindings grouped by prefix (`<leader>w`, `<leader>g`, `<leader>b`) and document intent in nearby comments.
- New plugins: add a spec to the matching `lua/plugins/*.lua` file (or a new file for a new concern), then commit the resulting `lazy-lock.json` change alongside it.

## Testing Guidelines
There is no automated test suite. For each change:
- Run `stylua init.lua lua after`.
- Run `nvim --headless "+checkhealth" +qa`.
- Open `nvim` and manually verify the affected behavior (keymaps, LSP attach, Telescope/Neogit flows, theme picker).

## Commit & Pull Request Guidelines
Use `<type>: <short imperative summary>` (for example: `feat: add telescope keymap for git files`, `chore: pin plugins to 2026-09`).

PRs should include:
- clear summary of behavior changes,
- touched modules/paths,
- manual verification steps and results,
- screenshots or GIFs for UI-visible changes when relevant.
