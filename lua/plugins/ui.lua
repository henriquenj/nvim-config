-- Interface: statusline, buffer tabs, file tree, keymap hints, indent guides.
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (single global line, like laststatus=3 in options.lua).
  -- Layout, icons and slanted separators follow NvChad's "default" statusline:
  -- mode | file | git ... diagnostics | lsp | cwd | cursor.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = function()
      local function lsp_clients()
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
          names[#names + 1] = client.name
        end
        if #names == 0 then
          return ""
        end
        return vim.o.columns > 100 and ("LSP ~ " .. table.concat(names, ", ")) or "LSP"
      end

      local function cwd()
        local path = vim.uv.cwd() or ""
        return path:match "([^/\\]+)[/\\]*$" or path
      end

      local function cursor()
        return string.format("%d/%d", vim.fn.line ".", vim.fn.virtcol ".")
      end

      -- Reuse the counts gitsigns already keeps instead of running git again.
      local function gitsigns_diff()
        local status = vim.b.gitsigns_status_dict
        return status and { added = status.added, modified = status.changed, removed = status.removed }
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "",
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "NvimTree" } },
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", file_status = false, path = 0, padding = { left = 0, right = 1 } },
          },
          lualine_c = {
            { "branch", icon = "" },
            { "diff", source = gitsigns_diff, symbols = { added = " ", modified = " ", removed = " " } },
          },
          lualine_x = {
            {
              "diagnostics",
              sections = { "error", "warn", "hint", "info" },
              symbols = { error = " ", warn = " ", hint = "󰛩 ", info = "󰋼 " },
            },
            { lsp_clients, icon = "" },
          },
          lualine_y = {
            {
              cwd,
              icon = "󰉋",
              cond = function()
                return vim.o.columns > 85
              end,
            },
          },
          lualine_z = { { cursor, icon = "" } },
        },
      }
    end,
  },

  -- Buffer tabs along the top.
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        show_close_icon = false,
        offsets = {
          { filetype = "NvimTree", text = "", separator = true },
        },
      },
    },
  },

  -- File tree.
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      filters = { dotfiles = false },
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      view = { width = 30, preserve_window_proportions = true },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
      },
    },
  },

  -- Keymap hints after a prefix key.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>f", group = "files" },
        { "<leader>g", group = "git" },
        { "<leader>p", group = "project" },
        { "<leader>q", group = "quit" },
        { "<leader>t", group = "toggles" },
        { "<leader>w", group = "windows" },
      },
    },
  },

  -- Indent guides.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { char = "│", show_start = false, show_end = false },
    },
  },
}
