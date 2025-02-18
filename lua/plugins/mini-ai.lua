return {
    "echasnovski/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local ai = require("mini.ai")
        ai.setup({
            n_lines = 500,
            custom_textobjects = {
                o = ai.gen_spec.treesitter({
                    a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                    i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                }),
                a = ai.gen_spec.treesitter({
                    a = { "@parameter.outer" },
                    i = { "@parameter.inner", "@parameter.outer" },
                }),
                f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                C = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
                r = ai.gen_spec.pair("[", "]", { type = "balanced" }),
                -- Whole buffer
                e = function()
                    local from = { line = 1, col = 1 }
                    local to = {
                        line = vim.fn.line("$"),
                        col = math.max(vim.fn.getline("$"):len(), 1),
                    }
                    return { from = from, to = to, vis_mode = "V" }
                end,
            },
        })
    end,
}
