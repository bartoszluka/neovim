return {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
        require("bqf").setup({
            auto_resize_height = true,
            preview = {
                winblend = 0,
                win_height = 999,
                show_scroll_bar = false,
            },
        })
    end,
}
