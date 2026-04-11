return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master', -- Essential for Neovim 0.10+ compatibility with this config style
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
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
        },
        auto_install = true,
        highlight = {
          enable = true, -- This restores your syntax highlighting
        },
        indent = {
          enable = true, -- This handles your Python indentation
        },
      }
    end,
  },
}
