return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-python',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- Added for better file picking
  },
  keys = {
    {
      '<leader>tT',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Run File',
    },
    {
      '<leader>tr',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run Nearest',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Toggle Summary',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open { enter = true, auto_close = true }
      end,
      desc = 'Show Output',
    },
    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Toggle Output Panel',
    },
    {
      '<leader>tS',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Stop',
    },
  },
  config = function()
    -- Function to load environment variables from .env file
    require('neotest').setup {
      adapters = {
        require 'neotest-python' {
          -- Use pytest as the test runner
          runner = 'pytest',
          -- Additional pytest arguments can be specified here
          args = { '--verbose' },
        },
      },
      -- Configure output window
      output = {
        open_on_run = true,
      },
      -- Configure summary window
      summary = {
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          expand = { '<CR>', '<2-LeftMouse>' },
          expand_all = 'e',
          output = 'o',
          short = 'O',
          run = 'r',
          run_marked = 'R',
          clear_marked = 'c',
          clear_target = 'C',
          mark = 'm',
          debug = 'd',
          attach = 'a',
          jumpto = 'i',
          stop = 's',
        },
      },
    }
  end,
}
