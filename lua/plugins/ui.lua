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
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = {
            -- colored = false so the icon picks up the section highlight and matches
            -- the filename next to it, the way NvChad's statusline paints it.
            { "filetype", icon_only = true, colored = false, separator = "", padding = { left = 1, right = 0 } },
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
        -- A single buffer needs no tab bar; bufferline drops `showtabline` to 0
        -- until a second one is open.
        always_show_bufferline = false,
      },
    },
  },

  -- File tree, opened as a floating window (sized like the Telescope pickers).
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false, -- neo-tree lazy-loads itself
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    ---@module "neo-tree"
    ---@type neotree.Config
    opts = {
      popup_border_style = "single",
      window = {
        position = "float",
        popup = {
          size = { height = "80%", width = "87%" },
          position = "50%",
        },
        mappings = {
          -- Same as <CR>: expand a folder / open a file. Overrides the global
          -- <Tab> buffer-cycling map inside the tree.
          ["<Tab>"] = "open",
        },
      },
      filesystem = {
        -- Show everything. Nothing is filtered out; dotfiles and gitignored
        -- entries are only dimmed (git status colors handle the latter).
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          hide_hidden = false,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
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
