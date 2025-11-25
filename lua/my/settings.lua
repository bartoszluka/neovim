-- local signs = { Error = " ", Warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
--     local hl = "DiagnosticSign" .. type
--     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end

vim.opt.listchars = {
    space = "·",
    tab = "→ ",
    -- tab = " ",
    trail = "·",
    extends = "»",
    precedes = "«",
    -- nbsp = "░",
    nbsp = "␣",
}
vim.opt.fillchars = {
    eob = " ",
    fold = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "›",
    vert = "▏",
}

vim.opt.shortmess:append("c") -- don't give completion-menu messages
nx.set({
    -- General
    clipboard = "unnamedplus", -- use system clipboard
    conceallevel = 0, -- do not hide characters like `` or * in help menu and others
    mouse = "a", -- allow mouse in all modes
    lazyredraw = true, -- pause redrawin when executing macros and other commands
    showmode = false, -- print vim mode on enter
    termguicolors = true, -- set term gui colors
    timeoutlen = 350, -- time to wait for a mapped sequence to complete
    list = true, -- Show some invisible characters
    undofile = true, -- enable persistent undo
    backup = false, -- create a backup file
    swapfile = false, -- create a swap file
    -- Command line
    cmdheight = 1,
    -- Completion menu
    pumheight = 14, -- completion popup menu height
    -- Gutter
    number = true, -- show line numbers
    numberwidth = 3, -- number column width - default "4"
    relativenumber = true, -- set relative line numbers
    signcolumn = "yes:2", -- use fixed width signcolumn - prevents text shift when adding signs
    -- Search
    hlsearch = false, -- highlight matches in previous search pattern
    ignorecase = true, -- ignore case in search patterns
    smartcase = true, -- use smart case - ignore case UNLESS /C or capital in search
    -- folds
    -- foldmethod = "expr",
    -- foldexpr = "v:lua.vim.treesitter.foldexpr",
    -- -- foldtext = "v:lua.vim.treesitter.foldtext()",
    -- foldenable = false, -- disable folds on start
    -- ...
    wrap = false, -- wrapping of text
    breakindent = true,
    updatetime = 1000, -- decrease update time
    hidden = true, -- Enable background buffers
    joinspaces = false, -- No double spaces with join
    scrolloff = 10, -- Lines of context
    shiftwidth = 4, -- Size of an indent
    tabstop = 4, -- Size of an indent
    expandtab = true, -- Use spaces instead of tabs
    sidescrolloff = 20, -- Columns of context
    splitbelow = true, -- Put new windows below current
    splitright = true, -- Put new windows right of current
    completeopt = "menu,menuone,noinsert", -- Set completeopt to have a better completion experience
    guicursor = "n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20",
    cursorline = true,
    laststatus = 3, -- global statusline
    guifont = "CaskaydiaCove Nerd Font Mono:h14",
    inccommand = "split", -- show the effects of a search / replace in a live preview window
    -- formatexpr = "v:lua.require'conform'.formatexpr()",
}, vim.opt)

nx.set({
    guifont = "FiraCode Nerd Font Mono:h9",
    -- guicursor = "n-v-sm:block,i-c-ci-ve:ver25,r-cr-o:hor20",
}, vim.go)

--  set border for floating windows
-- local border = {
--     { "🭽", "FloatBorder" },
--     { "▔", "FloatBorder" },
--     { "🭾", "FloatBorder" },
--     { "▕", "FloatBorder" },
--     { "🭿", "FloatBorder" },
--     { "▁", "FloatBorder" },
--     { "🭼", "FloatBorder" },
--     { "▏", "FloatBorder" },
-- }
-- local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
-- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
--     opts = opts or {}
--     opts.border = opts.border or border
--     return orig_util_open_floating_preview(contents, syntax, opts, ...)
-- end

local function prefix_diagnostic(prefix, diagnostic)
    return string.format(prefix .. " %s", diagnostic.message)
end

vim.diagnostic.config({
    virtual_text = {
        prefix = "",
        format = function(diagnostic)
            local severity = diagnostic.severity
            if severity == vim.diagnostic.severity.ERROR then
                return prefix_diagnostic("󰅚", diagnostic)
            end
            if severity == vim.diagnostic.severity.WARN then
                return prefix_diagnostic("⚠", diagnostic)
            end
            if severity == vim.diagnostic.severity.INFO then
                return prefix_diagnostic("ⓘ", diagnostic)
            end
            if severity == vim.diagnostic.severity.HINT then
                return prefix_diagnostic("󰌶", diagnostic)
            end
            return prefix_diagnostic("■", diagnostic)
        end,
    },
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
        focusable = true,
        style = "minimal",
        border = "single",
        source = "if_many",
        header = "",
        prefix = "",
    },
})

vim.opt.title = true
vim.opt.titlelen = 0
vim.opt.titlestring = "nvim " .. vim.fs.normalize(vim.uv.cwd() or "")
