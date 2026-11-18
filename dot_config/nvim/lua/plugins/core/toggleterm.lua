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
      -- Normal mode only: in terminal mode, Space then t while typing toggled the terminal away.
      -- From a terminal: <Esc><Esc> (keymaps.lua) to normal mode, then <leader>tt.
      vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })

      -- Send visual selection to terminal
      vim.keymap.set('v', '<leader>ts', function()
        require('toggleterm').send_lines_to_terminal('visual_selection', true, {})
      end, { desc = 'Send selection to terminal' })

      -- Terminal mode navigation
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        -- No single <esc> map: fzf, lazygit, yazi etc. need Esc. Use <Esc><Esc> or jk.
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        -- No <C-w> map: the shell needs it to delete a word.
      end
      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
    end,
  },
}
