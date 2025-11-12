return {
    "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local my_lsp = require("my.lsp")
        vim.lsp.config("*", {
            on_attach = my_lsp.on_attach,
            capabilities = my_lsp.make_capabilities(),
        })
    end,
}
