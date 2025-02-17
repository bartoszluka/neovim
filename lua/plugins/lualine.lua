return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
        local function lsp()
            local buf_id = vim.api.nvim_get_current_buf()
            local lsps = vim.lsp.get_clients({ bufnr = buf_id })
            local lsp_names = vim.iter(lsps)
                :map(function(server)
                    return server.name
                end)
                :join("+")
            return lsp_names
        end
        local theme = vim.g.colors_name or "auto"
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = theme,
                component_separators = "|",
                section_separators = "",
            },
            sections = {
                lualine_a = {
                    "mode",
                },
                lualine_b = {
                    "branch",
                },
                lualine_c = {
                    {
                        "filename",
                        file_status = true, -- Displays file status (readonly status, modified status)
                        newfile_status = true, -- Display new file status (new file means no write after created)
                        path = 4,
                        color = "Identifier"
                        -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory
                        -- 4: Filename and parent dir, with tilde as the home directory
                    },
                },
                lualine_x = {
                    {
                        lsp,
                        icon = " ",
                        color = "@function.call",
                    },
                    {
                        "diagnostics",
                        sources = { "nvim_diagnostic" },
                        colored = true,
                    },
                },
                lualine_y = {
                    -- "fileformat",
                    "filetype",
                    "encoding",
                },
                lualine_z = {
                    {
                        "location",
                        "selectioncount",
                    },
                },
            },
            inactive_sections = {
                lualine_b = {
                    {
                        "filename",
                        path = 0,
                        status = true,
                    },
                },
                lualine_x = { "filetype" },
            },
            tabline = {},
            extensions = {
                "quickfix",
                "oil",
                "toggleterm",
            },
        })
    end,
}
