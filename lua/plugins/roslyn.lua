return {
    "seblj/roslyn.nvim",
    event = { "BufReadPre", "BufNewFile" },
    ft = "cs",

    opts = {
        broad_search = true,
    },

    config = function()
        --local capabilities = require("blink.cmp").get_lsp().capabilities()
        local roslyn = require("roslyn")
        roslyn.setup({
            -- how to on_attach for roslyn lsp
            -- https://github.com/seblj/roslyn.nvim/issues/8#issuecomment-2198336099
            lock_target = false,
            ---@diagnostic disable-next-line: missing-fields
            config = {
                on_attach = function(client, bufnr)
                    require("my.lsp").on_attach(client, bufnr)
                end,
                settings = {
                    capabilities = require("my.lsp").make_capabilities(),

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
                        background_analysis = {
                            dotnet_analyzer_diagnostics_scope = "fullSolution",
                            dotnet_compiler_diagnostics_scope = "fullSolution",
                        },
                    },
                    ["csharp|completion"] = {
                        dotnet_show_completion_items_from_unimported_namespaces = true,
                        dotnet_show_name_completion_suggestions = true,
                    },
                    ["csharp|symbol_search"] = {
                        dotnet_search_reference_assemblies = true,
                    },
                },
            },
            -- vim.lsp.inlay_hint.enable(true),
        })
        nx.map({
            { "<leader>lf", vim.lsp.buf.format, desc = "format with lsp" },
            { "<leader>lr", cmd("Roslyn restart"), desc = "restart roslyn lsp server" },
        })
    end,
}
