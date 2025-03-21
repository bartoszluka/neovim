return {
    "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "Decodetalkers/csharpls-extended-lsp.nvim" },
    config = function()
        vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)
        local servers = require("my.lsp").servers
        local on_attach = require("my.lsp").on_attach
        local capabilities = require("my.lsp").make_capabilities()

        for _, lsp in ipairs(servers) do
            require("lspconfig")[lsp].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end

        -- Example custom configuration for lua
        --
        -- Make runtime files discoverable to the server
        local runtime_path = vim.split(package.path, ";", {})
        table.insert(runtime_path, "lua/?.lua")
        table.insert(runtime_path, "lua/?/init.lua")

        require("lspconfig").cssls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            cmd = { "vscode-css-language-server", "--stdio" },
        })
        require("lspconfig").lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
                        version = "LuaJIT",
                        -- Setup your lua path
                        path = runtime_path,
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = { enable = false },
                },
            },
        })
        if vim.tbl_contains(servers, "csharp_ls") then
            capabilities.workspace.symbol.dynamicRegistration = true
            require("lspconfig").csharp_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                handlers = {
                    ["textDocument/definition"] = require("csharpls_extended").handler,
                },
                settings = {
                    csharp = {
                        loglevel = "log",
                    },
                },
            })
        end
    end,
}
