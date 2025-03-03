return {
    "nvim-telescope/telescope.nvim",
    keys = {
        {
            "<leader>sf",
            function()
                require("telescope.builtin").find_files({
                    hidden = true,
                    -- no_ignore = true,
                })
            end,
            { desc = "find files" },
        },
        {
            "<leader>sg",
            function()
                require("telescope.builtin").live_grep()
            end,
            { desc = "live grep" },
        },
        {
            "<leader>sh",
            function()
                require("telescope.builtin").help_tags()
            end,
            { desc = "help tags" },
        },
        {
            "<leader>sq",
            function()
                require("telescope.builtin").command_history()
            end,
            { desc = "command history" },
        },
        {
            "<leader>ss",
            function()
                require("telescope.builtin").lsp_document_symbols()
            end,
            { desc = "lsp document symbols" },
        },
        {
            "<leader>sS",
            function()
                require("telescope.builtin").lsp_dynamic_workspace_symbols()
            end,
            { desc = "lsp workspace symbols" },
        },
        {
            "<leader>so",
            function()
                require("telescope.builtin").oldfiles()
            end,
            { desc = "old files" },
        },
        {
            "<leader>sr",
            function()
                require("telescope.builtin").resume()
            end,
            { desc = "resume last search" },
        },
        {
            "<leader>sb",
            function()
                require("telescope.builtin").buffers()
            end,
            { desc = "resume last search" },
        },
    },
    cmd = { "Telescope" },
    -- dependencies = {
    --     {
    --         "nvim-telescope/telescope-fzf-native.nvim",
    --         build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
    --     },
    --     "nvim-telescope/telescope-frecency.nvim",
    -- },
    dependencies = {
        "nvim-telescope/telescope-ui-select.nvim",
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        local layout_config = {
            vertical = {
                width = function(_, max_columns)
                    return math.floor(max_columns * 0.99)
                end,
                height = function(_, _, max_lines)
                    return math.floor(max_lines * 0.99)
                end,
                prompt_position = "bottom",
                preview_cutoff = 0,
            },
        }

        telescope.setup({
            defaults = {
                path_display = { "filename_first" },
                layout_strategy = "vertical",
                layout_config = layout_config,
                mappings = {
                    i = {
                        ["<C-q>"] = actions.smart_send_to_qflist,
                        -- ['<esc>'] = actions.close,
                        ["<C-s>"] = actions.cycle_previewers_next,
                        ["<C-a>"] = actions.cycle_previewers_prev,
                    },
                    n = {
                        ["<C-q>"] = actions.smart_send_to_qflist,
                        q = actions.close,
                    },
                },
                preview = {
                    treesitter = true,
                    check_mime_type = true,
                    timeout = 1000,
                },
                history = {
                    path = vim.fn.stdpath("data") .. "/telescope_history.sqlite3",
                    limit = 1000,
                },
                color_devicons = true,
                set_env = { ["COLORTERM"] = "truecolor" },
                prompt_prefix = "   ",
                selection_caret = "  ",
                entry_prefix = "  ",
                initial_mode = "insert",
                vimgrep_arguments = {
                    "rg",
                    "-L",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                },
            },
        })
        require("telescope").load_extension("ui-select")
        -- telescope.load_extension("fzf_native")
        -- require("telescope").load_extension("frecency")

        -- vim.keymap.set("n", "<leader>sf", function()
        --     require("telescope").extensions.frecency.frecency({
        --         workspace = "CWD",
        --     })
        -- end, { desc = "find files" })
    end,
}
