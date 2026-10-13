-- Optional: local LSP plugin from Dan's custom setup (macOS-specific path)
-- Only loads if the directory exists on this machine.
local di_lsp_path = '/Users/dan/custom_lsps/di_lsp/plugins/neovim/di-ls-plugin/'
if vim.fn.isdirectory(di_lsp_path) == 0 then
  return {}
end
return {
  dir = di_lsp_path,
}