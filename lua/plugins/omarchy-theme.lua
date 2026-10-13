-- Omarchy OS theme integration.
--
-- Reads the OS-generated ~/.local/state/omarchy/current/theme/neovim.lua,
-- which Omarchy regenerates on every theme change. Two shapes exist:
--
--   * aether themes (Omarchy 4 default/themed template, and custom themes):
--     a bjarneo/aether.nvim spec with the palette already injected, plus a
--     LazyVim entry naming "aether". We feed that palette straight to aether.
--   * native themes (shipped per-theme neovim.lua): a colorscheme plugin plus a
--     LazyVim entry naming the colorscheme (e.g. "tokyonight-night"). We load
--     the theme's plugin and apply the colorscheme.
--
-- This config drives its own colorscheme, so the LazyVim entry is only used as
-- a source of the colorscheme name (the config does not use LazyVim).
--
-- When not on Omarchy (OMARCHY_PATH unset), returns an empty spec so the
-- user's custom colorscheme.lua picks the default theme instead.

local IS_OMARCHY = vim.env.OMARCHY_PATH ~= nil

if not IS_OMARCHY then
  return {}
end

-- Omarchy writes the theme to $HOME/.local/state/omarchy (not nvim's own
-- stdpath('state')), matching omarchy-theme-set and the theme.lua symlink.
local theme_file = vim.fn.expand '~/.local/state/omarchy/current/theme/neovim.lua'

local aether_spec = nil
local colorscheme = nil
local theme_plugins = {}

local ok, spec = pcall(dofile, theme_file)
if ok and type(spec) == 'table' then
  for _, s in ipairs(spec) do
    if s[1] == 'bjarneo/aether.nvim' then
      aether_spec = s
    elseif s[1] == 'LazyVim/LazyVim' then
      colorscheme = s.opts and s.opts.colorscheme
    else
      theme_plugins[#theme_plugins + 1] = s
    end
  end
end

if aether_spec then
  -- Inject config: setup aether with the OS palette and apply it.
  aether_spec.config = function(_, opts)
    require('aether').setup(opts)
    vim.cmd.colorscheme('aether')
  end
  return { aether_spec }
end

if colorscheme then
  -- Native theme: declare the theme's plugin(s) so lazy loads them, then apply
  -- the colorscheme once startup has finished and they are available.
  --
  -- Applied from an autocmd rather than a lazy spec: lazy merges specs that
  -- share the same dir, and a second stdpath('config') spec would be folded
  -- into omarchy-theme-watcher and never load.
  --
  -- VimEnter, not VeryLazy: VeryLazy waits on UIEnter, which never fires in a
  -- headless session, and startup plugins are already loaded by VimEnter.
  vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('omarchy-colorscheme', { clear = true }),
    once = true,
    callback = function()
      -- Ensure the theme's plugin is loaded, then apply the colorscheme.
      if not pcall(vim.cmd.colorscheme, colorscheme) then
        pcall(function()
          require('lazy.core.loader').colorscheme(colorscheme)
        end)
      end

      -- transparency.lua is sourced at startup, i.e. before this, so re-apply
      -- it now or the colorscheme's backgrounds would win.
      local transparency_file = vim.fn.stdpath('config') .. '/plugin/after/transparency.lua'
      if vim.fn.filereadable(transparency_file) == 1 then
        pcall(vim.cmd.source, transparency_file)
      end

      vim.cmd 'redraw!'
    end,
  })
  return theme_plugins
end

-- Fallback: aether without OS colors (theme file missing or unreadable).
return {
  {
    'bjarneo/aether.nvim',
    branch = 'v3',
    name = 'aether',
    priority = 1000,
    config = function()
      pcall(require, 'aether')
      pcall(vim.cmd.colorscheme, 'aether')
    end,
  },
}
