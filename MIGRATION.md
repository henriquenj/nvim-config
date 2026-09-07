# Migrating a machine from the NvChad config

The rewrite (commit `9f49aed`) dropped NvChad, but a machine that ran the old
config still has NvChad's plugins and caches on disk. They do no harm, only
take space and clutter `:Lazy` and `:checkhealth`. This is how to clean them.

## 1. Pull and install the new config

```bash
git -C ~/.config/nvim pull
~/.config/nvim/bin/nvim-deploy
```

Do not start plain `nvim` between the pull and the deploy. lazy.nvim installs
missing plugins on any startup and rewrites `lazy-lock.json` afterwards from
the commits it finds on disk, so a single `nvim` (or `:checkhealth`) run on a
half-migrated machine replaces the pins with whatever the old config had. The
deploy script protects the file across its own runs; a manual start does not.

`nvim-deploy` clones the plugins the old config did not have at the commits in
`lazy-lock.json`, and moves the shared ones (Telescope, Neogit, cmp, Mason,
...) back down to those commits too, since NvChad tracked them at newer
revisions. Nothing is re-downloaded from scratch for the shared ones, they are
only checked out.

## 2. Remove the orphaned plugins

lazy.nvim keeps plugin directories that are no longer in any spec until told
otherwise. Seven are left over from NvChad:

| Directory under `~/.local/share/nvim/lazy/` | What it was                          |
|---------------------------------------------|--------------------------------------|
| `NvChad`                                    | NvChad core                          |
| `ui`                                        | NvChad statusline, tabufline, themes |
| `base46`                                    | NvChad highlight compiler            |
| `volt`, `menu`, `minty`                     | NvChad UI helpers and color pickers  |
| `cmp-async-path`                            | replaced by `cmp-path`               |

Remove them all with:

```bash
nvim --headless "+Lazy! clean" +qa
```

Or interactively: `:Lazy`, then press `X`. Afterwards the directory should
hold exactly the entries in `lazy-lock.json`:

```bash
ls ~/.local/share/nvim/lazy | wc -l   # 35
```

## 3. Remove NvChad's runtime directories

These were written by NvChad itself, not by lazy.nvim, so `Lazy clean` does
not know about them:

```bash
rm -rf ~/.local/share/nvim/base46     # compiled highlight cache
rm -rf ~/.local/share/nvim/nvnotify1  # NvChad UI notification store
```

## 4. What to keep

- `~/.local/share/nvim/mason/`: the language servers and stylua, still used.
- `~/.local/share/nvim/lazy/<plugin>` for every plugin in the lockfile.
- `~/.local/share/nvim/telescope_history`: Telescope prompt history.
- `~/.local/state/nvim/`: undo, shada, logs, and the new `colorscheme` file
  that stores the theme picked with `<leader>th`.
- `~/.cache/nvim/`: theme plugins compile their palettes here (catppuccin,
  nightfox, onedarkpro, tokyonight). Safe to delete, they regenerate.

## 5. Verify

```bash
nvim --headless "+checkhealth lazy" +qa
```

`:Lazy` should list 35 plugins with none marked as "not installed", and
`:checkhealth lazy` should report no missing or orphaned plugins.

If `:checkhealth lazy` warns about `~/.local/share/nvim/site/pack/core`, that
directory is not from NvChad: Neovim 0.12's built-in `vim.pack` creates it
empty on first use. Removing it silences the warning:

```bash
rmdir -p ~/.local/share/nvim/site/pack/core/opt 2>/dev/null || true
```
