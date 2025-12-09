vim.g.haskell_tools = {
    ---@type haskell-tools.lsp.ClientOpts
    ---You can also configure these via `:h vim.lsp.config`,
    --- with the "haskell-tools" key.
    hls = {
        ---@param client number The LSP client ID.
        ---@param bufnr number The buffer number
        ---@param ht HaskellTools = require('haskell-tools')
        on_attach = function(client, bufnr, ht)
            nx.map({
                { "<leader>le", ht.lsp.buf_eval_all },
                { "<leader>ls", ht.hoogle.hoogle_signature },
                {
                    "<leader>lr",
                    function()
                        client:stop()
                        ht.lsp.start(bufnr)
                    end,
                },
            }, { noremap = true, buffer = bufnr, silent = true })
        end,
        settings = {
            haskell = {
                plugin = {
                    semanticTokens = { globalOn = true },
                },
            },
        },
        -- ...
    },
}
