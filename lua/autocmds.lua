local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Treesitter highlighting for every filetype that has a parser available
-- (Neovim bundles c, lua, markdown, query, vim and vimdoc; nvim-treesitter
-- installs the rest, see lua/plugins/treesitter.lua).
autocmd("FileType", {
  group = augroup("treesitter_start", { clear = true }),
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
