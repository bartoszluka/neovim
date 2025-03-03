return {
    "0x00-ketsu/maximizer.nvim",
    keys = {
        {
            "<leader>m",
            function()
                require("maximizer").toggle()
            end,
            desc = "maximize window",
        },
    },
    config = function()
        require("maximizer").setup({})
    end,
}
