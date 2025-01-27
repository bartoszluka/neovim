return {
    "tenxsoydev/nx.nvim",
    priority = 1200,
    config = function()
        _G.nx = require("nx")
    end,
}
