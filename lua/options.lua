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

-- "unnamedplus" is served by a clipboard provider, and Neovim finds one by
-- itself wherever there is one: pbcopy on macOS, wl-copy or xsel/xclip under a
-- display server, win32yank on WSL, tmux's own buffers when $TMUX is set. It
-- does not fall back to OSC 52 while 'clipboard' is set, because the paste half
-- of OSC 52 queries the terminal and hangs on the many that never answer, so on
-- a bare machine (a plain ssh session, say) yanks would reach nothing at all.
-- Opt into OSC 52 there, where copying is an escape sequence the terminal
-- forwards to the system clipboard and needs nothing installed, and pasting
-- reads the last yank back rather than asking the terminal for it. Setting this
-- has to come before anything calls has("clipboard"), which freezes the choice.
if not (vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY or vim.env.TMUX) and vim.fn.has "mac" == 0 then
  local osc52 = require "vim.ui.clipboard.osc52"
  local function paste()
    return { vim.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" }
  end
  g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

o.cursorline = true
o.cursorlineopt = "number"
o.wrap = false -- keep long lines on one screen line

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
