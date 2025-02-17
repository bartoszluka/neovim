return {
    "echasnovski/mini.icons",
    version = false,
    event = "VeryLazy",
    config = function()
        local icons = require("mini.icons")
        icons.setup({
            style = "glyph",
        })
        icons.mock_nvim_web_devicons()
    end,
}
