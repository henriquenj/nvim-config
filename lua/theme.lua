-- Theme collection and switcher.
--
-- Colorscheme plugins live in lua/plugins/themes.lua. Any plugin that ships a
-- colors/ directory is treated as part of the collection, so adding a theme is
-- just adding a spec there. The selected theme is persisted per machine in
-- stdpath("state") and restored on startup; `M.default` is the fallback used on
-- a fresh machine.
local M = {}

M.default = "everforest"

-- Colorschemes shipped by the collection that should not be offered (compat shims).
M.hidden = { "catppuccin-nvim" }

local state_file = vim.fn.stdpath "state" .. "/colorscheme"

local function read_saved()
  local f = io.open(state_file, "r")
  if not f then
    return nil
  end
  local name = vim.trim(f:read "*a" or "")
  f:close()
  return name ~= "" and name or nil
end

function M.save(name)
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
  local f = assert(io.open(state_file, "w"))
  f:write(name, "\n")
  f:close()
end

--- Apply a colorscheme and remember it for the next start.
function M.set(name)
  vim.cmd.colorscheme(name)
  M.save(name)
end

--- Apply the saved theme, falling back to the default when it is missing.
function M.load()
  local name = read_saved() or M.default
  if pcall(vim.cmd.colorscheme, name) then
    return
  end
  vim.schedule(function()
    vim.notify(("Colorscheme %q is not available, falling back to %s"):format(name, M.default), vim.log.levels.WARN)
  end)
  if not pcall(vim.cmd.colorscheme, M.default) then
    vim.cmd.colorscheme "habamax"
  end
end

--- Plugin directories in the collection (every lazy.nvim plugin shipping colors/).
local function collection_dirs()
  local dirs = {}
  for _, plugin in pairs(require("lazy.core.config").plugins) do
    if vim.uv.fs_stat(plugin.dir .. "/colors") then
      dirs[#dirs + 1] = plugin.dir
    end
  end
  return dirs
end

--- Sorted names of every colorscheme in the collection. Read from disk, so
--- nothing has to be loaded to list them; lazy.nvim loads the owning plugin
--- when a scheme is applied.
function M.list()
  local hidden = {}
  for _, name in ipairs(M.hidden) do
    hidden[name] = true
  end
  local seen, names = {}, {}
  for _, dir in ipairs(collection_dirs()) do
    for _, f in ipairs(vim.fn.globpath(dir .. "/colors", "*", true, true)) do
      local ext = vim.fn.fnamemodify(f, ":e")
      local name = vim.fn.fnamemodify(f, ":t:r")
      if (ext == "lua" or ext == "vim") and not seen[name] and not hidden[name] then
        seen[name] = true
        names[#names + 1] = name
      end
    end
  end
  table.sort(names)
  return names
end

--- Telescope picker with live preview. Moving the cursor previews a theme,
--- <Esc> restores the previous one, <CR> applies and persists the choice.
function M.pick()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  local finders = require "telescope.finders"
  local pickers = require "telescope.pickers"

  local before = { name = vim.g.colors_name or M.default, background = vim.o.background }
  local chosen = nil

  local picker = pickers.new({}, {
    prompt_title = "Themes",
    finder = finders.new_table { results = M.list() },
    sorter = conf.generic_sorter {},
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection then
          chosen = selection.value
        end
        actions.close(prompt_bufnr)
        if chosen then
          M.set(chosen)
        end
      end)
      return true
    end,
  })

  -- Preview on cursor movement; restore the previous theme when cancelled.
  local set_selection = picker.set_selection
  picker.set_selection = function(self, row)
    set_selection(self, row)
    local selection = action_state.get_selected_entry()
    if selection then
      pcall(vim.cmd.colorscheme, selection.value)
    end
  end
  local close_windows = picker.close_windows
  picker.close_windows = function(status)
    close_windows(status)
    if not chosen then
      vim.o.background = before.background
      pcall(vim.cmd.colorscheme, before.name)
    end
  end

  picker:find()
end

return M
