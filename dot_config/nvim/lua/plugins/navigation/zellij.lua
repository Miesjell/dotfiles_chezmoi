return {
  'https://github.com/fresh2dev/zellij.vim',
  -- Pin version to avoid breaking changes.
  -- tag = '0.3.*',
  -- Disabled: built for the zellij-autolock plugin (not used), and it maps <C-h/j/k/l>
  -- over keymaps.lua. smart-splits.nvim (Alt+h/j/k/l) does the nvim <-> zellij navigation.
  enabled = false,
  lazy = false,
  init = function()
    -- Options:
    -- vim.g.zelli_navigator_move_focus_or_tab = 1
    -- vim.g.zellij_navigator_no_default_mappings = 1
  end,
}
