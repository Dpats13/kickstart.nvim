-- Build a dotted Django test label from the current file and cursor position.
-- Finds manage.py upward to determine the project root, then converts the
-- file path to a dotted module and optionally appends Class.method.
local function django_test_label(scope)
  local file = vim.fn.expand '%:p'
  if not file:match '%.py$' then
    return nil
  end

  local root = vim.fn.findfile('manage.py', file:match '(.*/)')
  if root == '' then
    root = vim.fn.findfile('manage.py', '.;')
  end
  if root == '' then
    return nil
  end
  root = vim.fn.fnamemodify(root, ':p:h')

  local rel = file:sub(#root + 2)
  local module = rel:gsub('%.py$', ''):gsub('/', '.')

  if scope == 'file' then
    return module
  end

  local line = vim.fn.line '.'
  local class_name, method_name
  for i = line, 1, -1 do
    local text = vim.fn.getline(i)
    if not method_name then
      local m = text:match '^%s+def%s+(test[%w_]*)'
      if m then
        method_name = m
      end
    end
    if not class_name then
      local c = text:match '^class%s+(%w+)'
      if c then
        class_name = c
        break
      end
    end
  end

  if class_name and method_name then
    return module .. '.' .. class_name .. '.' .. method_name
  elseif class_name then
    return module .. '.' .. class_name
  end
  return module
end

-- Run manage.py test in a terminal split. Inherits env vars already loaded
-- in the Neovim process (e.g. via :LoadDotEnv).
local function run_manage_test(scope)
  local manage = vim.fn.findfile('manage.py', '.;')
  if manage == '' then
    vim.notify('manage.py not found', vim.log.levels.ERROR)
    return
  end

  local cmd = 'uv run python manage.py test'
  if scope ~= 'all' then
    local label = django_test_label(scope)
    if label then
      cmd = cmd .. ' ' .. label
    end
  end

  vim.cmd('botright 15split | term ' .. cmd)
  vim.cmd 'startinsert'
end

return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-neotest/neotest-python',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
  },
  keys = {
    -- Neotest integration (test discovery and navigation, uses neotest-python's built-in DiscoverRunner)
    {
      '<leader>tT',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Run File (neotest)',
    },
    {
      '<leader>tr',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run Nearest (neotest)',
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
    -- Run via manage.py test (uses project's TEST_RUNNER, inherits env from :LoadDotEnv)
    {
      '<leader>td',
      function()
        run_manage_test 'nearest'
      end,
      desc = 'manage.py Test Nearest',
    },
    {
      '<leader>tD',
      function()
        run_manage_test 'file'
      end,
      desc = 'manage.py Test File',
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-python' {
          runner = 'django',
        },
      },
      output = {
        open_on_run = true,
      },
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
