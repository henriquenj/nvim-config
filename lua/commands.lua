-- User commands
-- Keep each command in its own section so this file scales cleanly.

-- TrimWhitespace
-- Removes trailing spaces in the current buffer while preserving window/cursor view.
local function trim_whitespace()
  local view = vim.fn.winsaveview()
  vim.cmd [[%s/\s\+$//e]]
  vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {
  desc = "Delete trailing whitespace in current buffer",
})

-- ToggleHardWrap
-- Toggles automatic hard line breaks at 80 columns for the current buffer.
-- Off by default; turn on when writing prose/markdown you want hard-wrapped.
local function toggle_hard_wrap()
  if vim.bo.textwidth == 0 then
    vim.bo.textwidth = 80
    vim.opt_local.formatoptions:append "t"
    vim.notify "Hard wrap ON (textwidth=80)"
  else
    vim.bo.textwidth = 0
    vim.opt_local.formatoptions:remove "t"
    vim.notify "Hard wrap OFF"
  end
end

vim.api.nvim_create_user_command("ToggleHardWrap", toggle_hard_wrap, {
  desc = "Toggle hard line breaks at 80 columns",
})

-- Theme
-- `:Theme` opens the picker; `:Theme <name>` applies and persists a theme.
vim.api.nvim_create_user_command("Theme", function(args)
  local theme = require "theme"
  if args.args == "" then
    theme.pick()
  else
    theme.set(args.args)
  end
end, {
  nargs = "?",
  complete = function(prefix)
    return vim.tbl_filter(function(name)
      return vim.startswith(name, prefix)
    end, require("theme").list())
  end,
  desc = "Pick or set the colorscheme (persisted across restarts)",
})
