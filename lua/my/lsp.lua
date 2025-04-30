--- @param opts vim.lsp.LocationOpts.OnList
local function my_references(opts)
    local refs = opts.items

    local replace_items = "r"
    if #refs == 0 then
        vim.notify("no references", vim.log.levels.INFO)
    elseif #refs == 1 then
        vim.fn.setqflist(refs, replace_items)
        vim.cmd.cfirst()
    else
        vim.fn.setqflist(refs, replace_items)
        vim.cmd.copen()
    end
end

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

return {
    on_attach = function(client, bufnr)
        monkey_patch_semantic_tokens(client)
        -- vim.cmd("autocmd! BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh({ bufnr = 0 })")
        vim.cmd("autocmd! BufEnter,BufWritePost <buffer> lua vim.lsp.codelens.refresh({ bufnr = 0 })")
        nx.map({
            {
                "K",
                function()
                    vim.lsp.buf.hover({ border = "single" })
                end,
                desc = "hover",
            },
            { "gd", vim.lsp.buf.definition, desc = "go to definition" },
            { "<leader>a", vim.lsp.buf.code_action, { "n", "v" }, desc = "code action" },
            { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
            {
                "grr",
                function()
                    ---@type lsp.ReferenceContext
                    local context = { includeDeclaration = false }
                    vim.lsp.buf.references(context, { on_list = my_references })
                end,
                desc = "go to references",
            },
            { "gra", vim.lsp.buf.code_action, desc = "code action" },
            { "grn", vim.lsp.buf.rename, desc = "code action" },
            { "gh", vim.diagnostic.open_float, desc = "open diagnostic" },
            { "<leader>ha", vim.lsp.codelens.run, desc = "code lens" },
        }, { buffer = bufnr })
    end,
    make_capabilities = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        -- local cmp_lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
        capabilities = vim.tbl_deep_extend("force", capabilities, blink_cmp_capabilities)
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
