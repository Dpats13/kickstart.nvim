-- nvim-treesitter setup for the `main` branch.
--
-- Neovim 0.12 requires the rewritten `main` branch (>= 0.12.0). The `master`
-- branch is locked for backward compatibility with Neovim <= 0.11 only, and its
-- `require('nvim-treesitter.configs')` API no longer exists on `main`.
--
-- On `main`, parsers are installed via install() and highlighting/indentation
-- are Neovim features enabled per-buffer (see the FileType autocmd below).
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- this plugin does not support lazy-loading
    build = ':TSUpdate',
    config = function()
      -- Parsers to install. `:TSUpdate` (the build step) keeps them current.
      require('nvim-treesitter').install {
        'bash',
        'c',
        'css',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'vim',
        'vimdoc',
        'vue',
        'javascript',
        'typescript',
        'hcl',
        'terraform',
        'tsx',
        'json',
      }

      -- Highlighting and indentation are built into Neovim on the `main`
      -- branch; enable them for every buffer that has a parser available.
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Enable treesitter highlighting and indentation',
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
