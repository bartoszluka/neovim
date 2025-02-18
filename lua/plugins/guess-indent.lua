return {
    "nmac427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "GuessIndent",
    config = function()
        require("guess-indent").setup({
            auto_cmd = true,
            override_editorconfig = true,
        })
    end,
}
