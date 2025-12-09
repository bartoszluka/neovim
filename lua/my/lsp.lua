--- @param client vim.lsp.Client the LSP client
local function monkey_patch_semantic_tokens(client)
    -- NOTE: Super hacky... Don't know if I like that we set a random variable on
    -- the client Seems to work though
    if client.is_hacked then
        return
    end
    client.is_hacked = true

    -- let the runtime know the server can do semanticTokens/full now
    client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
        semanticTokensProvider = {
            full = true,
        },
    })

    -- monkey patch the request proxy
    local request_inner = client.request
    function client:request(method, params, handler, req_bufnr)
        if method ~= vim.lsp.protocol.Methods.textDocument_semanticTokens_full then
            return request_inner(self, method, params, handler)
        end

        local target_bufnr = vim.uri_to_bufnr(params.textDocument.uri)
        local line_count = vim.api.nvim_buf_line_count(target_bufnr)
        local last_line = vim.api.nvim_buf_get_lines(target_bufnr, line_count - 1, line_count, true)[1]

        return request_inner(self, "textDocument/semanticTokens/range", {
            textDocument = params.textDocument,
            range = {
                ["start"] = {
                    line = 0,
                    character = 0,
                },
                ["end"] = {
                    line = line_count - 1,
                    character = string.len(last_line) - 1,
                },
            },
        }, handler, req_bufnr)
    end
end

local on_attach = function(client)
    monkey_patch_semantic_tokens(client)
end

local make_capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- local cmp_lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
    local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    capabilities = vim.tbl_deep_extend("force", capabilities, blink_cmp_capabilities)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    -- Add any additional plugin capabilities here.
    -- Make sure to follow the instructions provided in the plugin's docs.
    return capabilities
end

local servers = {
    nushell = {},
    ts_ls = {},
    lua_ls = {},
    jsonls = {},
    tinymist = {
        settings = {
            formatterMode = "typstyle",
            exportPdf = "onSave",
            -- outputPath = "$root/$name",
            semanticTokens = "enable",
            typingContinueCommentsOnNewline = false,
        },
    },
}

return {
    on_attach = on_attach,
    make_capabilities = make_capabilities,
    servers = servers,
    register_servers = function()
        for server_name, config in pairs(servers) do
            -- local merged_config = vim.tbl_extend("keep", config, {
            --     on_attach = on_attach,
            --     capabilities = make_capabilities(),
            -- })
            --
            -- vim.lsp.config[server_name] = merged_config
            vim.lsp.enable(server_name)
        end
    end,
}
