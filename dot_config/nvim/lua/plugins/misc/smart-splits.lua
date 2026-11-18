-- ~/.config/nvim/lua/plugins/smart-splits.lua  (lazy.nvim spec)
-- Only needed for STEP 2 in config.kdl (seamless Alt+hjkl across nvim splits and zellij panes).
--
-- Setup on the zellij side first:
--   mkdir -p ~/.config/zellij/plugins
--   curl -L -o ~/.config/zellij/plugins/vim-zellij-navigator.wasm \
--     https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm
-- A local file avoids zellij fetching unpinned code at runtime, and works behind a corporate proxy.
--
-- Test: open nvim, :vsplit, open a zellij pane to the right (Alt n).
-- Alt l should walk: left nvim window -> right nvim window -> zellij pane.

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- must load at startup so the multiplexer integration is ready
  config = function()
    local ss = require("smart-splits")
    ss.setup({}) -- zellij is detected automatically when nvim runs inside it

    vim.keymap.set("n", "<A-h>", ss.move_cursor_left, { desc = "Window/pane left" })
    vim.keymap.set("n", "<A-j>", ss.move_cursor_down, { desc = "Window/pane down" })
    vim.keymap.set("n", "<A-k>", ss.move_cursor_up, { desc = "Window/pane up" })
    vim.keymap.set("n", "<A-l>", ss.move_cursor_right, { desc = "Window/pane right" })
  end,
}
