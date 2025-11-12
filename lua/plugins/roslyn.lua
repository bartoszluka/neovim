---@param client vim.lsp.Client
---@param bufnr integer
local function roslyn_on_attach(client, bufnr)
    require("my.lsp").on_attach(client, bufnr)
    client.server_capabilities.diagnosticProvider = { workspaceDiagnostics = true }

    -- Workspace diagnostics: errors + warnings у quickfix
    vim.keymap.set("n", "<leader>ld", function()
        client.rpc.request("workspace/diagnostic", { previousResultIds = {} }, function(err, result)
            if err ~= nil or result == nil or result.items == nil then
                vim.notify(vim.inspect(err), vim.log.levels.ERROR)
            end
            -- local dupa = vim.iter(result.items)
            --     :filter(function(item)
            --         if #item.items == 0 then
            --             return false
            --         end
            --
            --         return vim.iter(item.items):all(function(subitem)
            --             return not (subitem.range == nil or subitem.message == nil)
            --         end)
            --     end)
            --     :map(function(item)
            --         return item.items
            --     end)
            --     :flatten()
            --     :totable()
            -- for _, diag in ipairs(result.items or {}) do
            --     local filepath = vim.uri_to_fname(diag.uri)
            --     if diag.items and #diag.items > 0 then
            --         for _, diag_line in ipairs(diag.items) do
            --             if diag_line.severity and diag_line.severity <= 2 then -- error + warning
            --                 local hash = diag_line.message
            --                     .. diag_line.range.start.line
            --                     .. diag_line.range.start.character
            --                     .. filepath
            --                 if not seen[hash] then
            --                     table.insert(diags, {
            --                         text = diag_line.message,
            --                         lnum = diag_line.range.start.line + 1,
            --                         col = diag_line.range.start.character + 1,
            --                         filename = filepath,
            --                     })
            --                     seen[hash] = true
            --                 end
            --             end
            --         end
            --     end
            -- end
            -- vim.fn.setqflist(diags)
            -- vim.cmd("silent! copen")
            -- vim.notify("Workspace diagnostics updated: " .. #diags .. " entries")
        end)
    end, { buffer = bufnr, noremap = true, silent = true, desc = "Roslyn Workspace Diagnostics" })

    nx.map({
        { "<leader>lr", cmd("Roslyn restart"), desc = "restart roslyn lsp server" },
    }, { buffer = bufnr, noremap = true, silent = true })
end
return {
    "seblj/roslyn.nvim",
    event = { "BufReadPre", "BufNewFile" },
    ft = "cs",
    keys = {
        { "<leader>rr", cmd("Roslyn restart") },
    },

    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
        broad_search = true,
    },

    config = function()
        --local capabilities = require("blink.cmp").get_lsp().capabilities()
        local capabilities = require("my.lsp").make_capabilities()
        capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
        capabilities.workspace.diagnostics.refreshSupport = true

        vim.lsp.config("roslyn", {
            cmd = {
                "dotnet",
                vim.fn.stdpath("data") .. "/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll",
                "--logLevel=Information",
                "--extensionLogDirectory=" .. vim.fn.stdpath("log"),
                "--stdio",
            },
            on_attach = roslyn_on_attach,
            settings = {
                capabilities = capabilities,

                -- ["csharp|inlay_hints"] = {
                --     csharp_enable_inlay_hints_for_implicit_object_creation = true,
                --     csharp_enable_inlay_hints_for_implicit_variable_types = true,
                --     csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                --     csharp_enable_inlay_hints_for_types = true,
                --     dotnet_enable_inlay_hints_for_indexer_parameters = true,
                --     dotnet_enable_inlay_hints_for_literal_parameters = true,
                --     dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                --     dotnet_enable_inlay_hints_for_other_parameters = true,
                --     dotnet_enable_inlay_hints_for_parameters = true,
                --     dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                --     dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                --     dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
                -- },
                ["csharp|code_lens"] = {
                    dotnet_enable_references_code_lens = true,
                },
                ["csharp|background_analysis"] = {
                    dotnet_compiler_diagnostics_scope = "openFiles",
                    dotnet_analyzer_diagnostics_scope = "openFiles",
                    -- dotnet_compiler_diagnostics_scope = "fullSolution",
                    -- dotnet_analyzer_diagnostics_scope = "fullSolution",
                },
                ["csharp|completion"] = {
                    dotnet_show_completion_items_from_unimported_namespaces = true,
                    dotnet_show_name_completion_suggestions = true,
                },
                ["csharp|symbol_search"] = {
                    dotnet_search_reference_assemblies = true,
                },
            },
        })
    end,
}
