nx.cmd({
    {
        "Reverse",
        function(args)
            if args.line1 == args.line2 then
                return
            end
            local buffer = vim.api.nvim_get_current_buf()
            local start_line, end_line = args.line1, args.line2
            local lines = vim.api.nvim_buf_get_lines(buffer, start_line - 1, end_line, false)
            local reversed_lines = {}

            for i = #lines, 1, -1 do
                table.insert(reversed_lines, lines[i])
            end

            vim.api.nvim_buf_set_lines(buffer, start_line - 1, end_line, false, reversed_lines)
        end,
        range = true,
        desc = "reverse selected lines",
    },
})

-- Function to search for Handle methods with specific parameter type
local function search_handle_methods(argument)
    argument = argument or ""

    -- Create the query for workspace symbols
    local params = {
        query = "Handle",
    }

    -- Request workspace symbols from LSP
    vim.lsp.buf_request_all(0, "workspace/symbol", params, function(response, _)
        -- Filter results for methods with matching parameter type
        local matches = vim.iter(response[1].result)
            :filter(function(symbol)
                vim.print(
                    symbol.name,
                    symbol.name:match("%f[%w]Handle%("),
                    symbol.name:match("%(" .. argument .. "%f[%W]")
                )
                return symbol.kind == vim.lsp.protocol.SymbolKind.Method
                    and symbol.location
                    and symbol.name
                    and symbol.name:match("%f[%w]Handle%(")
                    and symbol.name:match("%(" .. argument .. "%f[%W]")
            end)
            :map(function(symbol)
                -- You might need to adjust this based on your LSP server's response format
                local uri = symbol.location.uri or symbol.location.targetUri
                local range = symbol.location.range

                -- Add to matches if it meets criteria
                return {
                    filename = vim.uri_to_fname(uri),
                    lnum = range.start.line + 1,
                    col = range.start.character + 1,
                    text = symbol.name,
                }
            end)
            :totable()

        -- Display results in quickfix list
        vim.fn.setqflist(matches)
        vim.cmd.copen()
    end)
end

nx.cmd({
    {
        "SearchHandle",
        function(opts)
            search_handle_methods(opts.args)
        end,
        desc = "Search for Handle methods",
        nargs = 1,
    },
})
