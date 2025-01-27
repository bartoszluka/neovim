local spec_treesitter = require("mini.ai").gen_spec.treesitter
vim.b.miniai_config = {
    custom_textobjects = {
        t = spec_treesitter({ a = "@tag.outer", i = "@tag.inner" }),
    },
}
