return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        local Rule = require("nvim-autopairs.rule")
        local autopairs = require("nvim-autopairs")
        autopairs.setup({
            check_ts = true,
        })
        autopairs.add_rule(Rule('"""', '"""', "cs"))
    end,
}
