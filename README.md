# Spacemacs-inspired Neovim configuration

My personal Neovim configuration, written from scratch on top of
[lazy.nvim](https://github.com/folke/lazy.nvim). The keybindings are
Spacemacs-style because of years of deeply ingrained muscle memory, and the
deploy workflow mirrors the one in my [Doom Emacs
config](https://github.com/henriquenj/dotdoom): plugins are pinned to a tested
revision, work machines only ever move onto that pin.

Requires Neovim 0.11 or newer, `git`, `ripgrep`, and a C compiler (for the
Telescope fzf sorter). Language servers are installed by Mason on first start.

## Install

```bash
git clone https://github.com/henriquenj/nvim-config ~/.config/nvim && nvim
```

The first start clones lazy.nvim and installs every plugin at the commit
recorded in `lazy-lock.json`. A machine that previously ran the NvChad
version of this config should follow [MIGRATION.md](MIGRATION.md) to clear
out the leftovers.

## What is in the box

| Area       | Plugins                                                                                                   |
|------------|-----------------------------------------------------------------------------------------------------------|
| Packages   | lazy.nvim (with a committed lockfile)                                                                     |
| Git        | Neogit, diffview, gitsigns                                                                                |
| Fuzzy find | Telescope (+ fzf-native)                                                                                  |
| LSP        | nvim-lspconfig, Mason, mason-lspconfig, conform (formatting)                                              |
| Completion | nvim-cmp, LuaSnip, friendly-snippets, nvim-autopairs                                                      |
| Syntax     | nvim-treesitter                                                                                           |
| Interface  | lualine, bufferline, nvim-tree, which-key, indent-blankline                                               |
| Themes     | everforest (default), gruvbox-material, tokyonight, catppuccin, kanagawa, nightfox, rose-pine, onedarkpro |

Layout:

- `init.lua`: bootstraps lazy.nvim and loads the modules below.
- `lua/options.lua`, `lua/autocmds.lua`, `lua/commands.lua`, `lua/mappings.lua`: editor settings, autocommands, user commands, keymaps.
- `lua/theme.lua`: theme switcher (see below).
- `lua/plugins/*.lua`: one lazy.nvim spec file per concern (`themes`, `ui`, `telescope`, `git`, `lsp`, `completion`, `treesitter`).
- `lazy-lock.json`: the pinned plugin revisions.
- `bin/nvim-deploy`: moves an installed config onto the pinned revisions.

## Themes

`<leader>th` (or `:Theme`) opens a Telescope picker with live preview; `<CR>`
applies the theme and remembers it, `<Esc>` restores the previous one.
`:Theme <name>` sets one directly, with completion. The choice is stored per
machine in `stdpath("state")/colorscheme`; `M.default` in `lua/theme.lua` is
the fallback on a fresh machine.

Adding a theme is adding its plugin spec to `lua/plugins/themes.lua`. Any
plugin that ships a `colors/` directory is picked up automatically.

## Language servers

`lua/plugins/lsp.lua` lists the servers Mason installs (`lua_ls`, `html`,
`cssls`). Everything Mason has installed is enabled through mason-lspconfig,
so `:Mason` is enough to add another server. Per-server settings go through
`vim.lsp.config(...)` in the same file.

## Pinned plugin revisions

`lazy-lock.json` records the commit of every plugin this config is known to
work with. It is the Neovim counterpart of `doom-pin`: work machines follow the
lockfile rather than upstream, so an untested plugin commit never lands on a
machine I depend on.

### Deploy the pinned revisions (work machines)

```bash
git -C ~/.config/nvim pull
~/.config/nvim/bin/nvim-deploy
```

Installs anything missing at the locked commit and checks out the locked
commit for everything else (re-running build steps). Refuses to run if
`lazy-lock.json` has uncommitted changes, so a stray local update cannot be
mistaken for the pin.

Do not run `:Lazy update` or `:Lazy sync` on these machines. Both chase
upstream and rewrite the lockfile.

### Promote new revisions (test machine)

```bash
nvim "+Lazy update"
# ...use Neovim for a while...
git -C ~/.config/nvim commit lazy-lock.json -m 'Pin plugins to <date>'
```

`:Lazy update` moves plugins to their latest commits and rewrites
`lazy-lock.json` in place, so the diff is right there in `git status` for
review before it becomes the deployed revision. Rolling back is `git revert`
on that commit followed by a redeploy. `:Lazy restore` puts the local install
back onto the committed lockfile at any time.

## Bindings

| Binding            | Action                    | Spacemacs-style intent                    |
|--------------------|---------------------------|-------------------------------------------|
| `<leader><leader>` | Command palette           | Like `SPC SPC` command palette flow       |
| `<C-s>`            | Search in current buffer  | Fast in-buffer search workflow            |
| `<C-a>`            | Move to line start        | Emacs-style Home in n/v/i/c modes         |
| `<C-e>`            | Move to line end          | Emacs-style End in n/v/i/c modes          |
| `<C-j>` / `<C-k>`  | Scroll view down/up       | Scroll without moving the cursor          |
| `<C-h>` / `<C-l>`  | Move to left/right window | Quick window hop                          |
| `<C-n>`            | Toggle file tree          | Project drawer                            |
| `<leader>e`        | Focus file tree           | Jump into the project drawer              |
| `<leader>gs`       | Open Neogit UI            | Leader-based git status entry point       |
| `<leader>gfl`      | Git log for current file  | File-focused git history from leader menu |
| `<leader>gt`       | Git status (Telescope)    | Changed files picker                      |
| `<leader>bb`       | List/switch buffers       | Buffer switching from a leader prefix     |
| `<leader>bd`       | Delete current buffer     | Quick buffer close from buffer group      |
| `<leader>bn`       | New empty buffer          | Scratch space                             |
| `<leader><Tab>`    | Switch to last buffer     | Alternate between two buffers (`SPC TAB`) |
| `<Tab>` / `<S-Tab>`| Next/previous buffer      | Cycle the buffer tabs                     |
| `<leader>fs`       | Save file                 | File save under `SPC f`-style group       |
| `<leader>fr`       | Recent files              | Reopen recent files from file group       |
| `<leader>ff`       | Find files                | File picker from the current directory    |
| `<leader>fm`       | Format buffer             | conform, LSP fallback                     |
| `<leader>fh`       | Help tags                 | Search the manual                         |
| `<leader>qq`       | Quit Neovim (confirm)     | Prompt before quitting unsaved buffers    |
| `<leader>w<Tab>`   | Switch to previous window | Alternate between two windows             |
| `<leader>w=`       | Balance windows           | Quickly normalize split sizes             |
| `<leader>w_`       | Maximize window width     | Focus current split horizontally          |
| `<leader>wd`       | Delete window             | Close active split                        |
| `<leader>wh/j/k/l` | Move across windows       | Directional split navigation              |
| `<leader>wm`       | Toggle window maximize    | Maximize and restore current split        |
| `<leader>ws/wv`    | Split below / right       | Spacemacs `SPC w s` / `SPC w v`           |
| `<C-x>1`           | Close other windows       | Emacs-style single-window layout          |
| `<C-x>2`           | Split window below        | Emacs-style horizontal split              |
| `<C-x>3`           | Split window right        | Emacs-style vertical split                |
| `<leader>*`        | Grep word under cursor    | Search symbol/word across project         |
| `<leader>/`        | Live grep in repo         | Project-wide text search entry point      |
| `<leader>pf`       | Git files picker          | Fast project file jump from leader menu   |
| `<leader>th`       | Theme picker              | Live-preview colorscheme switcher         |
| `<leader>ds`       | Diagnostics to loclist    | Review problems in the current buffer     |
| `<leader>wK`       | Show all keymaps          | which-key overview                        |

With a language server attached: `gd` / `gD` definition and declaration,
`<leader>D` type definition, `<leader>ra` rename, `<leader>ca` code action,
plus Neovim's defaults (`K`, `grr`, `gri`, `gO`).

User commands: `:TrimWhitespace`, `:ToggleHardWrap`, `:Theme [name]`.
