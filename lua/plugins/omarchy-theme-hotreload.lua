-- Hot-reload the Omarchy theme when the OS changes it.
--
-- Omarchy's original version listened for a `User LazyReload` event, but
-- nothing in Omarchy currently fires that event — themes only update on
-- nvim restart. This version uses vim.uv.fs_poll() to watch the theme file
-- directly, giving real-time theme updates in a running Neovim.
--
-- Also listens for `User LazyReload` as a forward-compatible fallback if
-- Omarchy ever adds nvim IPC.

local IS_OMARCHY = vim.env.OMARCHY_PATH ~= nil

if not IS_OMARCHY then
  return {}
end

-- Omarchy writes the theme to $HOME/.local/state/omarchy (not nvim's own
-- stdpath('state')), matching omarchy-theme-set and the theme.lua symlink.
local theme_file = vim.fn.expand '~/.local/state/omarchy/current/theme/neovim.lua'
local transparency_file = vim.fn.stdpath('config') .. '/plugin/after/transparency.lua'

-- Shared reload function: re-reads the OS theme file and reapplies the
-- colorscheme (aether for aether-based themes, or native for others).
local function reload_theme()
  local ok, spec = pcall(dofile, theme_file)
  if not ok or not spec then
    return
  end

  local aether_spec = nil
  local colorscheme = nil

  for _, s in ipairs(spec) do
    if s[1] == 'bjarneo/aether.nvim' then
      aether_spec = s
    elseif s[1] == 'LazyVim/LazyVim' and s.opts and s.opts.colorscheme then
      colorscheme = s.opts.colorscheme
    end
  end

  if not aether_spec and not colorscheme then
    return
  end

  -- Clear highlights before reapplying
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end

  local target_cs
  if aether_spec and aether_spec.opts then
    -- Re-setup aether with new colors from the OS theme
    package.loaded['aether'] = nil
    local aether = require('aether')
    aether.setup(aether_spec.opts)
    target_cs = 'aether'
  else
    target_cs = colorscheme
  end

  -- Defer colorscheme + transparency so the new highlight groups load first
  vim.defer_fn(function()
    pcall(vim.cmd.colorscheme, target_cs)
    vim.cmd('redraw!')

    -- Re-apply transparency
    if vim.fn.filereadable(transparency_file) == 1 then
      pcall(vim.cmd.source, transparency_file)
    end
    vim.cmd('redraw!')
  end, 10)
end

return {
  {
    name = 'omarchy-theme-watcher',
    dir = vim.fn.stdpath('config'),
    lazy = false,
    priority = 1000,
    config = function()
      -- Watch the OS theme file for changes (polling — works everywhere)
      local handle = vim.uv.new_fs_poll()
      if handle then
        handle:start(theme_file, 1000, vim.schedule_wrap(reload_theme))
      end

      -- Forward-compatible: also listen for LazyReload event
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyReload',
        callback = reload_theme,
      })
    end,
  },
}