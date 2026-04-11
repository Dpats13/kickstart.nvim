return {
  '3rd/image.nvim',
  config = function()
    require('image').setup {
      backend = 'kitty', -- Warp Terminal supports the Kitty graphics protocol
      processor = 'magick_cli', -- Use the ImageMagick command line interface
      integrations = {
        markdown = {
          enabled = false, -- Disabled: triggers nvim-treesitter crash on Neovim 0.12
        },
        -- other integrations like neorg, typst can be enabled here
      },
      -- Other configurations...
      hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' }, -- Render image files as images when opened
    }
  end,
}
