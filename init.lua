-- Personal Neovim configuration. Plugins are managed by lazy.nvim and pinned
-- through lazy-lock.json (see README.md for the deploy/promote workflow).

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require "options"

-- Bootstrap lazy.nvim. The clone tracks `stable`; `Lazy restore` then moves it
-- (like every other plugin) onto the commit recorded in lazy-lock.json.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = { { import = "plugins" } },
  -- Everything loads at startup unless a spec says otherwise; the few heavier
  -- plugins declare their own cmd/event/keys triggers.
  defaults = { lazy = false },
  -- Missing plugins are installed at the commits recorded in the lockfile.
  lockfile = vim.fn.stdpath "config" .. "/lazy-lock.json",
  install = { colorscheme = { require("theme").default, "habamax" } },
  -- Updates are a deliberate act (`Lazy update` on the test machine), never a nag.
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "single" },
  -- No plugin here needs luarocks; skipping it keeps checkhealth quiet.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
}

require("theme").load()
require "autocmds"
require "commands"
require "mappings"
