-- Theme collection. Every plugin here ships a colors/ directory, which is how
-- lua/theme.lua discovers them; nothing else needs to be registered. They are
-- lazy-loaded: lazy.nvim loads the right plugin when `:colorscheme` (or the
-- picker) asks for one of its schemes.
return {
  -- The default theme (see lua/theme.lua) loads first, before anything else draws.
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.everforest_background = "medium" -- hard / medium / soft
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 0
    end,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
    end,
  },
  { "folke/tokyonight.nvim", lazy = true }, -- tokyonight{,-night,-storm,-moon,-day}
  { "catppuccin/nvim", name = "catppuccin", lazy = true }, -- catppuccin{,-latte,-frappe,-macchiato,-mocha}
  { "rebelot/kanagawa.nvim", lazy = true }, -- kanagawa{,-wave,-dragon,-lotus}
  { "EdenEast/nightfox.nvim", lazy = true }, -- nightfox, duskfox, nordfox, terafox, carbonfox, dawnfox, dayfox
  { "rose-pine/neovim", name = "rose-pine", lazy = true }, -- rose-pine{,-main,-moon,-dawn}
  { "olimorris/onedarkpro.nvim", lazy = true }, -- onedark, onedark_vivid, onedark_dark, onelight, vaporwave
}
