return {
  'mbbill/undotree',
  cmd = 'UndotreeToggle',
  keys = {
    { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = 'Toggle Undotree' },
  },
  config = function()
    -- vim.g.undotree_WindowLayout = 2 -- Set the layout to vertical split
    -- vim.g.undotree_SplitWidth = 35 -- Set the width of the
    -- vim.g.undotree_SetFocusWhenToggle = 1 -- Focus on the undotree window when toggled
    -- vim.g.undotree_HelpLine = 0 -- Disable the help line
    -- vim.g.undotree_ShortIndicators = 1 -- Use short indicators for the undo tree
    -- vim.g.undotree_TreeNodeShape = 'round' -- Use round shape for tree nodes
  end,
}
