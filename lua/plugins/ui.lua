-- Interface: statusline, buffer tabs, file tree, keymap hints, indent guides.
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (single global line, like laststatus=3 in options.lua).
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "NvimTree" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "lsp_status", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
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
