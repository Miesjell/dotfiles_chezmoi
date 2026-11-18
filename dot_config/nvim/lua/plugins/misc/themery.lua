return {
  {
    'lmantw/themify.nvim',
    lazy = false,
    priority = 999,

    config = function()
      require('themify').setup {
        -- Your list of colorschemes.
        'default',
        'comfysage/evergarden',
        'maxmx03/fluoromachine.nvim',
        { 'ellisonleao/gruvbox.nvim', priority = 1000, config = true },
        'sho-87/kanagawa-paper.nvim',
        { 'folke/tokyonight.nvim', transparent = vim.g.transparent_enabled },
      }
    end,
  },
  { 'xiyaowong/transparent.nvim' },
}
