return {
    on_attach = function(client, bufnr)
        -- vim.cmd("autocmd! BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh({ bufnr = 0 })")
        vim.cmd("autocmd! BufEnter,BufWritePost <buffer> lua vim.lsp.codelens.refresh({ bufnr = 0 })")
        nx.map({
            { "gd", vim.lsp.buf.definition, desc = "go to definition" },
            { "<leader>a", vim.lsp.buf.code_action, { "n", "v" }, desc = "code action" },
            { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
            { "grr", vim.lsp.buf.references, desc = "go to references" },
            { "gra", vim.lsp.buf.code_action, desc = "code action" },
            { "grn", vim.lsp.buf.rename, desc = "code action" },
            { "gh", vim.diagnostic.open_float, desc = "open diagnostic" },
            { "<leader>ha", vim.lsp.codelens.run, desc = "code lens" },
        }, { buffer = bufnr })
    end,
    make_capabilities = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- Add com_nvim_lsp capabilities
        local cmp_lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        capabilities = vim.tbl_deep_extend("keep", capabilities, cmp_lsp_capabilities)
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        -- Add any additional plugin capabilities here.
        -- Make sure to follow the instructions provided in the plugin's docs.
        return capabilities
    end,

    servers = {
        "ts_ls",
        "lua_ls",
        "cssls",
        -- "csharp_ls",
        "jsonls",
        -- "omnisharp",
    },
}
