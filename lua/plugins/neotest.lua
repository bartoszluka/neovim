return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "Issafalcon/neotest-dotnet",
    },
    keys = {
        {
            "<leader>tt",
            function()
                require("neotest").run.run()
            end,
        },
        {
            "<leader>tr",
            function()
                require("neotest").run.run()
            end,
        },
        {
            "<leader>ts",
            function()
                require("neotest").run.stop()
            end,
        },
        {
            "<leader>tl",
            function()
                require("neotest").run.run_last()
            end,
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
        },
        {
            "<leader>to",
            function()
                require("neotest").output.open({
                    enter = true,
                    auto_close = true,
                    quiet = true,
                })
            end,
        },
        {
            "]n",
            function()
                require("neotest").jump.next({ status = "failed" })
            end,
        },
        {
            "[n",
            function()
                require("neotest").jump.prev({ status = "failed" })
            end,
        },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-dotnet"),
            },
        })
    end,
}
