-- Personal Neovim configuration. Plugins are managed by lazy.nvim and pinned
-- through lazy-lock.json (see README.md for the deploy/promote workflow).

-- Everything below assumes vim.uv (0.10) and vim.lsp.config (0.11). Without
-- this guard an older Neovim dies partway through with a message about the
-- missing API rather than about its version, and, headless, still exits 0, so
-- bin/nvim-deploy reported a successful deploy on a machine where lazy.nvim had
-- never run.
if vim.fn.has "nvim-0.11" ~= 1 then
  local v = vim.version()
  local msg = ("This configuration requires Neovim 0.11 or newer; this is %d.%d.%d. Nothing was loaded."):format(
    v.major,
    v.minor,
    v.patch
  )
  vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","

require "options"

-- Bootstrap lazy.nvim at the commit recorded in lazy-lock.json. lazy.nvim runs
-- a few lines below, before it has read any lockfile of its own, so this is the
-- one plugin that has to be pinned by hand: cloning a branch would execute
-- whatever its tip happens to hold. `--no-checkout` keeps that tip out of the
-- working tree entirely. `stable` is the fallback for a config with no lockfile.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
local lockfile = vim.fn.stdpath "config" .. "/lazy-lock.json"

local function lazy_pin()
  local f = io.open(lockfile, "r")
  if not f then
    return nil
  end
  local ok, lock = pcall(vim.json.decode, f:read "*a")
  f:close()
  return ok and type(lock) == "table" and lock["lazy.nvim"] and lock["lazy.nvim"].commit or nil
end

if not vim.uv.fs_stat(lazypath) then
  local function git(...)
    local out = vim.fn.system { "git", ... }
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({ { "Failed to bootstrap lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  git("clone", "--filter=blob:none", "--no-checkout", "https://github.com/folke/lazy.nvim.git", lazypath)
  git("-C", lazypath, "checkout", lazy_pin() or "stable")
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
