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

-- Popups are drawn flush with the editor, the way NvChad draws them. Most
-- themes give NormalFloat a lighter background than Normal, which turns a
-- bordered float into a raised slab: the border glyph occupies a whole cell, so
-- what the eye reads as the frame is that cell's background, not the thin glyph
-- inside it. Painting floats with the Normal background leaves only the glyph,
-- a hairline, to delimit the window.
local function flatten_floats()
  local function hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
  end

  local bg = hl("Normal").bg
  if not bg then
    return -- transparent background: nothing to match against
  end

  -- Perceived brightness, enough to tell "invisible" from "dim but readable".
  -- Some themes (catppuccin) colour FloatBorder to match the float it encloses,
  -- which vanishes once that float takes the editor background; those fall back
  -- to the comment colour, which every theme keeps readable against Normal.
  local function brightness(rgb)
    local r, g, b = math.floor(rgb / 65536) % 256, math.floor(rgb / 256) % 256, rgb % 256
    return 0.299 * r + 0.587 * g + 0.114 * b
  end

  local border = hl "FloatBorder"
  local fg = border.fg
  if not fg or math.abs(brightness(fg) - brightness(bg)) < 25 then
    fg = hl("Comment").fg
  end

  vim.api.nvim_set_hl(0, "NormalFloat", vim.tbl_extend("force", hl "NormalFloat", { bg = bg }))
  vim.api.nvim_set_hl(0, "FloatBorder", vim.tbl_extend("force", border, { fg = fg, bg = bg }))
end

autocmd("ColorScheme", {
  group = augroup("flat_floats", { clear = true }),
  callback = flatten_floats,
})

-- init.lua applies the saved theme before requiring this file, so the autocmd
-- above has already missed the first colorscheme.
flatten_floats()

-- Markdown is where prose gets written here (prompts, notes, READMEs), so it
-- starts hard-wrapped instead of waiting for `:ToggleHardWrap`. Buffer-local,
-- so the command still flips it off for a buffer that wants long lines.
autocmd("FileType", {
  group = augroup("markdown_hard_wrap", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.bo.textwidth = 80
    vim.opt_local.formatoptions:append "t"
  end,
})
