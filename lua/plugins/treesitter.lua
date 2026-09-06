-- nvim-treesitter (main branch) manages parsers and queries. Highlighting is
-- started by the FileType autocmd in lua/autocmds.lua. Installing extra parsers
-- needs the `tree-sitter` CLI and a C compiler; Neovim's bundled parsers
-- (c, lua, markdown, query, vim, vimdoc) work without either.
local ensure_installed = {
  "bash",
  "cpp",
  "json",
  "python",
  "toml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ts = require "nvim-treesitter"
      ts.setup {}
      if vim.fn.executable "tree-sitter" == 1 then
        ts.install(ensure_installed)
      end
    end,
  },
}
