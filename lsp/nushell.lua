---@type vim.lsp.Config
return {
    cmd = { "nu", "--lsp" },
    on_attach = require("my.lsp").on_attach,
    capabilities = require("my.lsp").make_capabilities(),
    single_file_support = true,
}
