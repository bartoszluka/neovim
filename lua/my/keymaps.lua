nx.map({
    { "L", "$", { "n", "v", "o" }, silent = true },
    { "H", "0", { "n", "v", "o" }, silent = true },
})

-- Remap for dealing with word wrap
-- nx.map({
--     { "k", "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true },
--     { "j", "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true },
-- })

-- vim.on_key(function(char)
--     if vim.fn.mode() == "n" then
--         local is_search_key = vim.tbl_contains({ "n", "N", "*", "#", "/", "?" }, vim.fn.keytrans(char))
--         if is_search_key and (not vim.opt.hlsearch:get()) then
--             vim.opt.hlsearch = true
--         end
--     end
-- end)

-- nx.map({
--     "<Esc>",
--     function()
--         --  TODO: don't close toggleterm
--         close_all_floating_windows()
--         if vim.opt.hlsearch:get() then
--             vim.opt.hlsearch = false
--         end
--         -- return "<Esc>"
--     end,
--     mode = { "n" },
--     silent = true,
--     noremap = true,
-- })

nx.map({
    { "<leader>q", "<cmd>confirm quit<CR>", desc = "quit" },
    { "<leader>u", "g~l", desc = "swap case" },
    { "<leader>w", "<cmd>write<CR>", desc = "write file", silent = true },
    { "<leader>W", "<cmd>write<CR>", desc = "write file" },
})

-- local modes = { "n", "v", "t" }
-- nx.map({
--     { "<C-j>", "<C-w>j", modes, desc = "focus window to the bottom" },
--     { "<C-k>", "<C-w>k", modes, desc = "focus window to the top" },
--     { "<C-l>", "<C-w>l", modes, desc = "focus window to the right" },
--     { "<C-h>", "<C-w>h", modes, desc = "focus window to the left" },
-- })

-- nx.map({
--     { ";", ":", { "n", "v" }, silent = false }, -- map ';' to start command mode
--     { "<C-l>", "<Right>", { "c" }, silent = false },
-- })

nx.map({
    "<leader>bo",
    function()
        require("my.bufonly").bufonly(false)
    end,
})

---@param direction "next"|"prev"
function diagnostic_iterator(direction)
    local severities = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
        vim.diagnostic.severity.INFO,
        vim.diagnostic.severity.HINT,
    }
    local func = direction == "next" and vim.diagnostic.get_next or vim.diagnostic.get_prev
    return function()
        for _, severity in pairs(severities) do
            local diag = func({ severity = severity })
            if diag ~= nil then
                return diag
            end
        end
        return nil
    end
end

local function get_next_diag()
    local next_error = vim.diagnostic.get_next({ severity = vim.diagnostic.severity.ERROR })
    local next_warn = vim.diagnostic.get_next({ severity = vim.diagnostic.severity.WARN })
    local next_info = vim.diagnostic.get_next({ severity = vim.diagnostic.severity.INFO })
    local next_hint = vim.diagnostic.get_next({ severity = vim.diagnostic.severity.HINT })
    local next_diag = vim.iter({ next_error, next_warn, next_info, next_hint }):next()
    return next_diag
end

local function get_prev_diag()
    local prev_error = vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.ERROR })
    local prev_warn = vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.WARN })
    local prev_info = vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.INFO })
    local prev_hint = vim.diagnostic.get_prev({ severity = vim.diagnostic.severity.HINT })

    local prev_diag = vim.iter({ prev_error, prev_warn, prev_info, prev_hint }):next()
    return prev_diag
end

nx.map({
    {
        "]e",
        function()
            vim.diagnostic.jump({ count = 1, float = true, severity = { min = vim.diagnostic.severity.ERROR } })
        end,
        desc = "next error",
    },
    {
        "[e",
        function()
            vim.diagnostic.jump({ count = -1, float = true, severity = { min = vim.diagnostic.severity.ERROR } })
        end,
        desc = "next error",
    },
    {
        "]d",
        function()
            local next_diag = get_next_diag()
            if not next_diag then
                return
            end

            vim.diagnostic.jump({ diagnostic = next_diag, float = true })
        end,
    },
    {
        "[d",
        function()
            local prev_diag = get_prev_diag()
            if not prev_diag then
                return
            end

            vim.diagnostic.jump({ diagnostic = prev_diag, float = true })
        end,
    },
}, { silent = true })

nx.map({ "gh", vim.diagnostic.open_float, desc = "open diagnostic" })
