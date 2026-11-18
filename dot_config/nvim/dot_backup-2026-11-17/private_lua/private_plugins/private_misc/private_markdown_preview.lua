return {
  'toppair/peek.nvim',
  event = { 'VeryLazy' },
  build = 'deno task --quiet build:fast',
  keys = {
    {
      '<leader>mp',
      function()
        local peek = require 'peek'
        if peek.is_open() then
          peek.close()
        else
          peek.open()
        end
      end,
      desc = 'Peek (Markdown Preview)',
    },
  },
  opts = { theme = 'dark', app = 'browser' },
}

-- return -- install with yarn or npm
-- {
--   'iamcco/markdown-preview.nvim',
--   cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
--   build = 'cd app && npm install',
--   init = function()
--     vim.g.mkdp_filetypes = { 'markdown' }
--   end,
--   ft = { 'markdown' },
--   keys = {
--     { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview' },
--   },
-- }
