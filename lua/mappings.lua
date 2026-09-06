-- Keymaps. Spacemacs-style leader groups on top of a handful of the NvChad
-- defaults this config used to inherit. Plugin-specific maps that only make
-- sense inside a buffer (LSP) live next to the plugin in lua/plugins/.
local map = vim.keymap.set

-- Lazily resolve a telescope.builtin picker so telescope is loaded on first use.
local function telescope(picker, opts)
  return function()
    require("telescope.builtin")[picker](opts)
  end
end

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })

-- Emacs-style line navigation in normal/insert/cmdline contexts.
map("n", "<C-a>", "0", { desc = "Line start" })
map("n", "<C-e>", "$", { desc = "Line end" })
map("v", "<C-a>", "0", { desc = "Line start" })
map("v", "<C-e>", "$", { desc = "Line end" })
map("i", "<C-a>", "<C-o>0", { desc = "Line start" })
map("i", "<C-e>", "<End>", { desc = "Line end" })
map("c", "<C-a>", "<Home>", { desc = "Cmdline start" })
map("c", "<C-e>", "<End>", { desc = "Cmdline end" })

-- Insert-mode cursor movement without leaving insert mode.
map("i", "<C-b>", "<ESC>^i", { desc = "Move to beginning of line" })
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

-- Scroll view without moving cursor
map("n", "<C-j>", "<C-e>", { desc = "Scroll down" })
map("n", "<C-k>", "<C-y>", { desc = "Scroll up" })

--------------------------------------------------------------------------------
-- Windows (Spacemacs-style under SPC w)
--------------------------------------------------------------------------------
local function toggle_window_maximize()
  local current_win = vim.api.nvim_get_current_win()
  local tab = vim.t

  if tab.zoomed_win == current_win and tab.zoom_restore_cmd then
    vim.cmd(tab.zoom_restore_cmd)
    tab.zoomed_win = nil
    tab.zoom_restore_cmd = nil
    return
  end

  tab.zoomed_win = current_win
  tab.zoom_restore_cmd = vim.fn.winrestcmd()
  vim.cmd "wincmd |"
  vim.cmd "wincmd _"
end

map("n", "<leader>w<Tab>", "<C-w>p", { desc = "Switch to previous window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Balance windows" })
map("n", "<leader>w_", "<C-w>|", { desc = "Maximize window width" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete window" })
map("n", "<leader>wh", "<C-w>h", { desc = "Move to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Move to window below" })
map("n", "<leader>wk", "<C-w>k", { desc = "Move to window above" })
map("n", "<leader>wl", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>wm", toggle_window_maximize, { desc = "Toggle window maximize" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split window below" })
map("n", "<leader>wv", "<C-w>v", { desc = "Split window right" })
map("n", "<C-h>", "<C-w>h", { desc = "Switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch window right" })

-- Emacs-style window shortcuts.
map("n", "<C-x>1", "<C-w>o", { desc = "Close other windows" })
map("n", "<C-x>2", "<C-w>s", { desc = "Split window below" })
map("n", "<C-x>3", "<C-w>v", { desc = "Split window right" })

--------------------------------------------------------------------------------
-- Command palette
--------------------------------------------------------------------------------
-- Telescope builtin.commands only lists user/plugin commands.
-- This uses Vim command completion so <leader><leader> behaves closer to Spacemacs M-x.
local function command_palette()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local conf = require("telescope.config").values
  local finders = require "telescope.finders"
  local pickers = require "telescope.pickers"

  local commands = vim.fn.getcompletion("", "command")
  table.sort(commands)

  pickers
    .new({}, {
      prompt_title = "Command Palette",
      finder = finders.new_table { results = commands },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not selection then
            return
          end

          -- Insert the selected command into ":" prompt so args can be typed before execution.
          local cmd = selection[1] or selection.value
          local keys = vim.api.nvim_replace_termcodes(":" .. cmd .. " ", true, false, true)
          vim.api.nvim_feedkeys(keys, "nt", false)
        end)
        return true
      end,
    })
    :find()
end

map("n", "<leader><leader>", command_palette, { desc = "Command palette (all commands)" })

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------
map("n", "<C-s>", telescope "current_buffer_fuzzy_find", { desc = "Search in the buffer" })
map({ "n", "v" }, "<leader>*", telescope "grep_string", { desc = "Search word under cursor" })
map("n", "<leader>/", telescope "live_grep", { desc = "Search whole repo" })
map("n", "<leader>fw", telescope "live_grep", { desc = "Live grep" })

--------------------------------------------------------------------------------
-- Files and projects
--------------------------------------------------------------------------------
map("n", "<leader>pf", telescope "git_files", { desc = "Search files in repo" })
map("n", "<leader>ff", telescope "find_files", { desc = "Find files" })
map("n", "<leader>fa", telescope("find_files", { follow = true, no_ignore = true, hidden = true }), {
  desc = "Find all files",
})
map("n", "<leader>fr", telescope "oldfiles", { desc = "Recent files" })
map("n", "<leader>fo", telescope "oldfiles", { desc = "Recent files" })
map("n", "<leader>fh", telescope "help_tags", { desc = "Help tags" })
map("n", "<leader>fs", "<cmd>w<CR>", { desc = "Save file" })
map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format file" })

-- File tree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file tree" })

--------------------------------------------------------------------------------
-- Buffers
--------------------------------------------------------------------------------
map("n", "<leader>bb", telescope "buffers", { desc = "Move between buffers" })
map("n", "<leader>fb", telescope "buffers", { desc = "Find buffers" })
map("n", "<leader>bd", "<cmd>confirm bdelete<CR>", { desc = "Close current buffer" })
map("n", "<leader>x", "<cmd>confirm bdelete<CR>", { desc = "Close current buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

--------------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------------
map("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "Show Neogit UI" })
map("n", "<leader>gfl", telescope "git_bcommits", { desc = "Git log of current file" })
map("n", "<leader>gt", telescope "git_status", { desc = "Git status (Telescope)" })
map("n", "<leader>cm", telescope "git_commits", { desc = "Git commits" })

--------------------------------------------------------------------------------
-- Diagnostics, themes, help
--------------------------------------------------------------------------------
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "Diagnostics loclist" })
map("n", "<leader>th", function()
  require("theme").pick()
end, { desc = "Pick theme" })
map("n", "<leader>wK", "<cmd>WhichKey<CR>", { desc = "All keymaps (which-key)" })

--------------------------------------------------------------------------------
-- Quit
--------------------------------------------------------------------------------
map("n", "<leader>qq", "<cmd>confirm qa<CR>", { desc = "Quit Neovim" })
