local function concat_tables(t1, t2)
    local result = {}
    for _, v in ipairs(t1) do
        table.insert(result, v)
    end
    for _, v in ipairs(t2) do
        table.insert(result, v)
    end
    return result
end

return {
    "mfussenegger/nvim-lint",
    -- event = "BufWritePost",
    ft = { "cs", "typescript", "markdown" },
    config = function()
        local eslint = require("lint").linters.eslint
        local args = { "run", "lint:ci", "--silent", "--", "--format", "json" }
        require("lint").linters.npm_run_lint = {
            cmd = "npm",
            stdin = false, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
            append_fname = false, -- Automatically append the file name to `args` if `stdin = false` (default: true)
            args = args, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
            stream = "stdout", -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
            ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
            env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
            parser = eslint.parser,
        }

        require("lint").linters_by_ft = {
            markdown = {
                -- "markdownlint-cli2",
                "vale",
                "codespell",
            },
            -- lua = { "selene" },
            cs = { "cspell" },
            typescript = { "cspell", "npm_run_lint" },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
                -- try_lint without arguments runs the linters defined in `linters_by_ft`
                -- for the current filetype
                require("lint").try_lint()

                -- You can call `try_lint` with a linter name or a list of names to always
                -- run specific linters, independent of the `linters_by_ft` configuration
                -- require("lint").try_lint("cspell")
            end,
        })
    end,
}
