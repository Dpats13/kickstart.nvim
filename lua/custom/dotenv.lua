-- Load environment variables from a .env file
local function load_dotenv(filepath)
  filepath = filepath or '.env'
  local file = io.open(filepath, 'r')
  if not file then
    print('Could not open ' .. filepath)
    return
  end

  for line in file:lines() do
    for key, value in string.gmatch(line, '([%w_]+)%s*=%s*(.*)') do
      -- Remove surrounding quotes if present
      value = value:gsub('^["\']', ''):gsub('["\']$', '')
      vim.fn.setenv(key, value)
    end
  end

  file:close()
  print('Loaded environment variables from ' .. filepath)
end

-- Command to manually run it from Neovim
vim.api.nvim_create_user_command('LoadDotEnv', function(opts)
  load_dotenv(opts.args ~= '' and opts.args or nil)
end, { nargs = '?', complete = 'file' })
