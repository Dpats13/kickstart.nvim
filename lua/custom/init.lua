function setColorScheme(scheme)
  vim.cmd.colorscheme(scheme)

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
end

setColorScheme 'rose-pine'
