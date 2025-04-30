return {
    "mawkler/demicolon.nvim",
    keys = { ";", ",", "t", "f", "T", "F", "]", "[", "]d", "[d" }, -- Uncomment this to lazy load
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
        diagnostic = {
            -- See `:help vim.diagnostic.Opts.Float`
            float = {},
        },
        -- Create default keymaps
        keymaps = {
            -- Create t/T/f/F key mappings
            horizontal_motions = true,
            -- Create ]d/[d, etc. key mappings to jump to diganostics. See demicolon.keymaps.create_default_diagnostic_keymaps
            diagnostic_motions = true,
            -- Create ; and , key mappings
            repeat_motions = true,
            -- Create ]q/[q/]<C-q>/[<C-q> and ]l/[l/]<C-l>/[<C-l> quickfix and location list mappings
            list_motions = true,
            -- Create `]s`/`[s` key mappings for jumping to spelling mistakes
            spell_motions = true,
            -- Create `]z`/`[z` key mappings for jumping to folds
            fold_motions = true,
        },
        integrations = {
            -- Integration with https://github.com/lewis6991/gitsigns.nvim
            gitsigns = {
                enabled = true,
                keymaps = {
                    next = "]h",
                    prev = "[h",
                },
            },
            -- Integration with https://github.com/nvim-neotest/neotest
            neotest = {
                enabled = false,
                keymaps = {
                    test = {
                        next = "]t",
                        prev = "[t",
                    },
                    failed_test = {
                        next = "]T",
                        prev = "[T",
                    },
                },
            },
        },
    },
}
