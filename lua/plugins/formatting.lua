return {
    "stevearc/conform.nvim",
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({
                    async = true,
                    lsp_fallback = true,
                })
            end,
            desc = "format file",
        },
    },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                -- Conform will run multiple formatters sequentially
                python = { "isort", "ruff_format" },
                -- Use a sub-list to run only the first available formatter
                javascript = {
                    -- "biome",
                    "prettier",
                    stop_after_first = true,
                },
                typescript = {
                    -- "biome",
                    "prettier",
                    stop_after_first = true,
                },
                yaml = { "prettier" },
                json = { "prettier" },
                json5 = { "prettier" },
                jsonc = { "prettier" },
                css = { "prettier" },
                fish = { "fish_indent" },
                xml = { "xq" },
                sh = { "shfmt" },
                c = { "clang_format" },
                cs = { "injected", "csharpier", stop_after_first = false },
                fsharp = { "fantomas" },
                -- ps1 = { "psformat" },
                markdown = {
                    "injected",
                    -- "mdslw",
                    "prettier",
                    stop_after_first = false,
                },
                nix = { "alejandra" },
                haskell = { "fourmolu" },
                tex = { "latexindent", "trim_whitespace" },
                go = { "gofumpt" },
                sql = { "sql_formatter" },
                just = { "just" },
                html = { "prettierd", "prettier", stop_after_first = true },
                java = { "google-java-format" },
                -- Use the "*" filetype to run formatters on all filetypes.
                ["*"] = { "trim_whitespace" },
                -- Use the "_" filetype to run formatters on filetypes that don't have other formatters configured.
                ["_"] = { "trim_whitespace" },
            },

            formatters = {
                prettier = {
                    append_args = { "--no-color" },
                },
                biome = {
                    command = "biome",
                    stdin = true,
                    args = { "format", "--indent-style=space", "--stdin-file-path", "$FILENAME" },
                    cwd = require("conform.util").root_file({ ".editorconfig" }),
                },
                fourmolu = {
                    range_args = function(ctx)
                        return { "--start-line", ctx.range.start[1], "--end-line", ctx.range["end"][1] }
                    end,
                },
                alejandra = {
                    command = "alejandra",
                    args = { "-qq" },
                    stdin = true,
                },
                mdslw = {
                    prepend_args = { "--max-width", "110" },
                },
                fantomas = {
                    command = "fantomas",
                    args = { "$FILENAME" },
                    stdin = false,
                },
                xq = {
                    -- This can be a string or a function that returns a string.
                    -- When defining a new formatter, this is the only field that is *required*
                    command = "xq",
                    -- A list of strings, or a function that returns a list of strings
                    -- Return a single string instead of a list to run the command in a shell
                    args = { "--indent", "4" },

                    -- Send file contents to stdin, read new contents from stdout (default true)
                    -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
                    -- file is assumed to be modified in-place by the format command.
                    stdin = true,
                    -- A function that calculates the directory to run the command in
                    cwd = require("conform.util").root_file({ ".editorconfig" }),
                },
                sql_formatter = {
                    cwd = require("conform.util").root_file({ ".sql-formatter.json" }),
                },
                just = {
                    command = "just",
                    args = { "--dump", "-f", "$FILENAME" },
                    stdin = true,
                },
                psformat = {
                    command = "pwsh",
                    args = { "-Command", "ps-format", '"$FILENAME"' },
                    stdin = false,
                },
                injected = {
                    options = {
                        -- Set to true to ignore errors
                        ignore_errors = false,
                        -- Map of treesitter language to file extension
                        -- A temporary file name with this extension will be generated during formatting
                        -- because some formatters care about the filename.
                        lang_to_ext = {
                            bash = "sh",
                            c_sharp = "cs",
                            csharp = "cs",
                            elixir = "exs",
                            javascript = "js",
                            typescript = "ts",
                            julia = "jl",
                            latex = "tex",
                            markdown = "md",
                            python = "py",
                            ruby = "rb",
                            rust = "rs",
                            teal = "tl",
                        },
                        -- Map of treesitter language to formatters to use
                        -- (defaults to the value from formatters_by_ft)
                        -- lang_to_formatters = {},
                    },
                },
            },
        })
    end,
}
