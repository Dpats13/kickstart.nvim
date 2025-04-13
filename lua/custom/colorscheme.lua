function setColorScheme(scheme)
  vim.cmd.colorscheme(scheme)

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
end

-- Function to show colorscheme picker
function ColorSchemePicker()
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values

  -- Get list of installed colorschemes
  local colors = vim.fn.getcompletion('', 'color')

  pickers
    .new({}, {
      prompt_title = 'Color Schemes',
      finder = finders.new_table {
        results = colors,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          setColorScheme(selection[1])
        end)
        return true
      end,
    })
    :find()
end

-- Set up the keybinding
vim.keymap.set('n', '<leader>cs', ColorSchemePicker, { desc = 'Pick Color Scheme' })

-- Set initial colorscheme
setColorScheme 'rose-pine'
