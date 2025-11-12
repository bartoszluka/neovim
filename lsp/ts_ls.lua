---@type vim.lsp.Config
return {
    on_attach = require("my.lsp").on_attach,
    capabilities = require("my.lsp").make_capabilities(),
}
