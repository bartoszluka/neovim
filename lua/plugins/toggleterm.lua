local ctrl_t = "<C-t>"

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { ctrl_t },
    cmd = { "ToggleTerm" },
    config = function()
        require("toggleterm").setup({
            open_mapping = ctrl_t,
            shell = "pwsh",
            direction = "float",
            float_opts = {
                border = "single",
                title_pos = "rounded",
            },
        })
    end,
}
