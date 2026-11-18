-- Treesitter: syntax highlighting from real parsers instead of regexes.
--
-- nvim-treesitter has two incompatible branches:
--   * master: frozen, the old `configs` setup, for Neovim 0.11
--   * main:   the rewrite, needs Neovim 0.12+, the `tree-sitter` CLI (>= 0.26.1) and a C compiler
-- This file picks the right one per machine, so CachyOS and the VDI can run different Neovim versions.
--
-- Check it works: open a Python file, put the cursor on `def`, run :Inspect
-- -> the output must contain a "Treesitter" section.

local parsers = {
  -- from your original list
  'bash', 'c', 'diff', 'html', 'latex', 'lua', 'luadoc', 'markdown', 'markdown_inline',
  'query', 'regex', 'toml', 'qmljs', 'vim', 'vimdoc',
  -- your work stack
  'python', 'sql', 'yaml', 'json', 'hcl', 'terraform', 'dockerfile', 'gitcommit',
}

if vim.fn.has 'nvim-0.12' == 1 then
  return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- this plugin does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      if type(ts.install) ~= 'function' then
        -- The checkout on disk is still the old master branch (e.g. lazy-lock.json pinned it).
        vim.notify('nvim-treesitter is still on master: run :Lazy sync, then restart', vim.log.levels.WARN)
        return
      end
      ts.install(parsers) -- async; no-op for parsers already installed
      -- Highlighting is built into Neovim now; start it for every buffer that has a parser.
      -- No parser for a filetype? :TSInstall <language> (main has no auto_install).
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-treesitter-start', { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  }
end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- hands `opts` to the module that actually reads them
  opts = {
    ensure_installed = parsers,
    auto_install = true,
    highlight = { enable = true }, -- was missing: treesitter highlighting was off
  },
}
