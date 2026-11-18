return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Animations making it easier to see what's happening
    -- require('mini.animate').setup()

    -- Move around selected text; alt + hjkl
    -- mini.move defaults to Alt+h/j/k/l, which zellij and smart-splits already use for
    -- window/pane navigation. Moved to Alt+Shift+h/j/k/l (works in normal and visual mode).
    require('mini.move').setup {
      mappings = {
        left = '<M-H>', right = '<M-L>', down = '<M-J>', up = '<M-K>',
        line_left = '<M-H>', line_right = '<M-L>', line_down = '<M-J>', line_up = '<M-K>',
      },
    }

    require('mini.starter').setup {
      -- header = table.concat({
      --   [[  /\ \▔\___  ___/\   /(●)_ __ ___  ]],
      --   [[ /  \/ / _ \/ _ \ \ / / | '_ ` _ \ ]],
      --   [[/ /\  /  __/ (_) \ V /| | | | | | |]],
      --   [[\_\ \/ \___|\___/ \_/ |_|_| |_| |_|]],
      --   [[───────────────────────────────────]],
      --   }, '\n'),
      content_hooks = {
        require('mini.starter').gen_hook.aligning('center', 'center'),
      },

      header = table.concat({
        [[    ▓█████████▌▄                                            ▄▄▄█████]],
        [[     ▓███████████▌▓                                    ▄▄███████████]],
        [[      ▓█████████████▌▄                            ▄▄▌██████████████▌]],
        [[       ░▓██████████████▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▌████████████████████▓]],
        [[         ░▓█████████████████████████████████████████████████████▓▓  ]],
        [[           ▒▀████████████████████████████████████████████████▀▓░░   ]],
        [[             ▒▓▓▓██████████████████████████████████████████▓░       ]],
        [[              ▒███████████████████████████████████████▌▓▓▒░         ]],
        [[              ▓█████████████████████████████████████████▓░          ]],
        [[             ▓█████▓▓▓░▒▓█████████████████▓▓▄░░▓█████████▓          ]],
        [[            ░█████▌▓░▒  ░▓███████████████▌▓░░  ░▓█████████▒         ]],
        [[            ▓███████▓▒░░▓█████████████████▌▄▒░░▓██████████▌         ]],
        [[           ░████████████████▌▓▒ ▒▓█████████████████████████▒        ]],
        [[            ░░▒▓▓███████████████████████████████▌▓▓▓▓▓▓████▓        ]],
        [[           ▓▓▓▓▓▓▓█████████████████████████████▌▓▓▓▓▓▓▓▓████▒       ]],
        [[           ▓▓▓▓▓▓███████████▓▓░░▒▓▓▓▓▓█████████▌▓▓▓▓▓▓▓▓▓███▌       ]],
        [[           ▓▓▒▒▓▓███████████▌▒░▓█████▓▓▓█████████▓▓▓▓▓▓▓▓█████▓     ]],
        [[           ▓█████████████████▓▒▓█████▓▓████████████████████████▒    ]],
        [[           ▓█████████████████▌▓▓▓▓▓▒▓▓████████████████████████▓     ]],
        [[           ▓█████████████████████████████████████████████████▌░     ]],
        [[           ░░▓█████████████████████████████████████████████████▓    ]],
      }, '\n'),
      footer = os.date(),
      items = {
        { action = ':lua require("telescope").extensions.zoxide.list()', name = 'z: choose directory (zoxide)', section = 'Actions' },
        { action = ':Telescope find_files', name = 'find files (telescope)', section = 'Actions' },
        { action = ':Neotree reveal', name = '\\: filetree toggle (neotree)', section = 'Actions' },
        {
          action = ':lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })',
          name = 'neovim config files (telescope)',
          section = 'Actions',
        },
        { action = '<leader>sk', name = 'keybindings (whichkey)', section = 'Actions' },

        { action = ':Telescope oldfiles', name = 'recent files (telescope)', section = 'Actions' },

        { action = ':Themify', name = 'change colorscheme (themify)', section = 'System' },
        { action = ':Lazy update', name = 'update plugins (Lazy)', section = 'System' },
        { action = ':qall!', name = 'quit neovim', section = 'System' },
      },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
