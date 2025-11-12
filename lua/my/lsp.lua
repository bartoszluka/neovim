--- @param str string|nil
--- @return boolean
local function is_empty(str)
    return str == "" or str == nil
end

--- @param client vim.lsp.Client
--- @param refs vim.quickfix.entry[]
--- @return vim.quickfix.entry[]
local function remove_declaration(client, refs)
    local win = vim.api.nvim_get_current_win()
    local position = vim.lsp.util.make_position_params(win, client.offset_encoding)

    local response, client_error = client:request_sync("textDocument/definition", position, 1000)
    if client_error ~= nil then
        vim.notify(vim.inspect(client_error), vim.log.levels.ERROR)
        return refs
    end
    if response ~= nil and response.err ~= nil then
        vim.notify(vim.inspect(response.err), vim.log.levels.ERROR)
        return refs
    end
    if response == nil then
        return refs
    end

    local def_positions = response.result ---@as lsp.Position
    local filtered = vim.iter(refs)
        :filter(function(item)
            local ref_position = item.user_data ---@as lsp.Position
            return not vim.tbl_contains(def_positions, function(definition_position)
                return vim.deep_equal(definition_position, ref_position)
            end, { predicate = true })
        end)
        :totable()
    return filtered
end

--- @param opts vim.lsp.LocationOpts.OnList
--- @param references_of string
--- @param client vim.lsp.Client
local function my_references(opts, references_of, client)
    local refs = opts.items ---@as vim.quickfix.entry[]

    if client.name == "roslyn" then
        refs = remove_declaration(client, refs)
    end

    if #refs == 0 then
        vim.notify("no references", vim.log.levels.INFO)
        return
    end

    local option = " " -- push to the quickfix stack
    vim.fn.setqflist(refs, option)
    vim.fn.setqflist({}, "a", { title = ("references of `%s`"):format(references_of) })
    if #refs == 1 then
        vim.cmd("silent! cfirst")
    else
        vim.cmd("silent! copen")
    end
end

local function do_rename(new_name)
    if is_empty(new_name) then
        return
    end

    local split = vim.split(new_name, " ", { plain = true, trimempty = true })
    if #split == 1 then
        return vim.lsp.buf.rename(new_name)
    end

    -- more than one word, convert to camelCase
    local first_word = split[1]:lower()
    local capitalized = vim.iter(split)
        :skip(1)
        :map(function(word)
            local first_char = string.sub(word, 1, 1)
            local rest = string.sub(word, 2)
            return first_char:upper() .. rest
        end)
        :join("")
    return vim.lsp.buf.rename(first_word .. capitalized)
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

--- @type string|nil
_G.last_new_name = nil

--- wraps rename so that it is dot-repeatable
_G.my_rename_wrapped = function(name)
    if not name then
        last_new_name = nil
        vim.go.operatorfunc = "v:lua.global_my_rename"
        return "g@l"
    end
    do_rename(name)
end

_G.global_my_rename = function()
    if is_empty(last_new_name) then
        vim.ui.input({ prompt = "new name: " }, function(new_name)
            if is_empty(new_name) then
                return
            end
            last_new_name = new_name
            do_rename(last_new_name)
        end)
        return
    end

    do_rename(last_new_name)
end

local on_attach = function(client, bufnr)
    monkey_patch_semantic_tokens(client)
    nx.map({
        {
            "K",
            function()
                vim.lsp.buf.hover({ border = "single" })
            end,
            desc = "hover",
        },
        { "gd", vim.lsp.buf.definition, desc = "go to definition" },
        { "gtd", vim.lsp.buf.type_definition, desc = "go to type definition" },
        { "<leader>a", vim.lsp.buf.code_action, { "n", "v" }, desc = "code action" },
        { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
        {
            "grr",
            function()
                ---@type lsp.ReferenceContext
                local context = { includeDeclaration = false }
                local word_under_cursor = vim.fn.expand("<cword>")
                vim.lsp.buf.references(context, {
                    on_list = function(opts)
                        my_references(opts, word_under_cursor, client)
                    end,
                })
            end,
            desc = "go to references",
        },
        { "gra", vim.lsp.buf.code_action, desc = "code action" },
        {
            "grn",
            my_rename_wrapped,
            expr = true,
            desc = "rename",
        },
        { "gh", vim.diagnostic.open_float, desc = "open diagnostic" },
        { "<leader>ha", vim.lsp.codelens.run, desc = "code lens" },
        {
            "<leader>lf",
            function()
                vim.lsp.buf.format({ bufnr = bufnr, async = true })
            end,
            desc = "lsp format",
        },
    }, { buffer = bufnr, silent = true, noremap = true })
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

nx.au({
    "LspAttach",
    callback = function(event)
        local bufnr = event.buf
        nx.map({
            {
                "K",
                function()
                    vim.lsp.buf.hover({ border = "single" })
                end,
                desc = "hover",
            },
            { "gd", vim.lsp.buf.definition, desc = "go to definition" },
            { "gtd", vim.lsp.buf.type_definition, desc = "go to type definition" },
            { "<leader>a", vim.lsp.buf.code_action, { "n", "v" }, desc = "code action" },
            { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
            {
                "grr",
                function()
                    ---@type lsp.ReferenceContext
                    local context = { includeDeclaration = false }
                    local word_under_cursor = vim.fn.expand("<cword>")
                    vim.lsp.buf.references(context, {
                        on_list = function(opts)
                            local client = vim.lsp.get_client_by_id(event.data.client_id)
                            my_references(opts, word_under_cursor, client)
                        end,
                    })
                end,
                desc = "go to references",
            },
            { "gra", vim.lsp.buf.code_action, desc = "code action" },
            { "grn", vim.lsp.buf.rename, desc = "rename" },
            { "gh", vim.diagnostic.open_float, desc = "open diagnostic" },
            { "<leader>ha", vim.lsp.codelens.run, desc = "code lens" },
        }, { buffer = bufnr })
    end,
}, { nested = true, create_group = "LspKeymaps" })

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
