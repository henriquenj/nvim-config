-- Editor options. These mirror the NvChad defaults this config grew out of, so
-- the editor keeps feeling the same after the rewrite.
local opt = vim.opt
local o = vim.o
local g = vim.g

o.laststatus = 3 -- single global statusline
o.showmode = false -- lualine shows the mode
o.splitkeep = "screen"
o.termguicolors = true

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

-- Numbers
o.number = true
o.numberwidth = 2
o.ruler = false

-- Disable the intro message and the "search hit BOTTOM" chatter.
opt.shortmess:append "sI"

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true

-- Interval for writing the swap file to disk, also used by gitsigns.
o.updatetime = 250

-- Go to previous/next line with h, l, and the arrow keys at line boundaries.
opt.whichwrap:append "<>[]hl"

-- Disable unused remote-plugin providers (faster startup, cleaner checkhealth).
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
