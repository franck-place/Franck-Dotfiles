vim.g.italic_comments = true
vim.g.italic_keywords = true
vim.g.italic_functions = true
vim.g.italic_variables = true
lvim.transparent_window = true


lvim.plugins = {
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
  },

{
  "ggandor/leap.nvim",
  enabled = true,
  name = "leap",
  config = function()
    require("leap").add_default_mappings()
  end,
},
{
  'wfxr/minimap.vim',
  -- install code-minimap with paru or yay
  init = function ()
    vim.cmd ("let g:minimap_width = 10")
    vim.cmd ("let g:minimap_auto_start = 1")
    vim.cmd ("let g:minimap_auto_start_win_enter = 1")
  end,
}
}
