-- In-buffer Markdown preview. Markview handles attaching to supported buffers.
return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      experimental = {
        -- The internal link opener builds an Ex command from the link path.
        prefer_nvim = false,
      },
      preview = {
        -- Preserve Neovim's existing gx behavior in Markdown buffers.
        map_gx = false,
      },
    },
  },
}
