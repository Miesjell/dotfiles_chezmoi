return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        open_mapping = nil, -- We'll set our own mapping below
        insert_mappings = false,
        terminal_mappings = false,
      }

      -- Toggle terminal
      vim.keymap.set({ 'n', 't' }, '<leader>t', '<cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })

      -- Send visual selection to terminal
      vim.keymap.set('v', '<leader>t', function()
        require('toggleterm').send_lines_to_terminal('visual_selection', true, {})
      end, { desc = 'Send selection to terminal' })

      -- Terminal mode navigation
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end
      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
    end,
  },
}
