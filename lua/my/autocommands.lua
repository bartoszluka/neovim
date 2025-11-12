vim.filetype.add({
    filename = {
        ["flake.lock"] = "json",
        [".swcrc"] = "json",
    },
    extension = {
        ll = "llvm",
    },
    pattern = {
        -- ["*.[cf]sproj"] = "xml",
        ["Directory.*.props"] = "xml",
    },
})

nx.au({
    "FileType",
    desc = "fix commentstring for c-like languages",
    pattern = { "c", "cpp", "cs", "java", "fsharp" },
    command = "setlocal commentstring=//%s",
}, { nested = true, create_group = "FixCommentString" })

nx.au({
    "FileType",
    desc = "fix commentstring for markdown",
    pattern = "markdown",
    command = [[setlocal commentstring=<!--\ %s\ -->]],
}, { nested = true, create_group = "FixMarkdownCommentString" })

nx.au({
    "BufWinEnter",
    desc = "disable extending comments with 'o'",
    pattern = "*",
    callback = function()
        vim.opt.formatoptions:remove("o")
        vim.opt_local.formatoptions:remove("o")
    end,
    nested = true,
}, { create_group = "DisableExtendingComments" })

nx.au({
    "BufEnter",
    desc = "start in insert mode in git commit message buffer if the line is empty",
    pattern = "*COMMIT_EDITMSG",
    callback = function()
        local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)
        if line ~= nil and #line[1] == 0 then
            vim.cmd.startinsert()
        end
    end,
    nested = true,
}, { create_group = "GitCommitStartInsert" })

nx.au({
    "BufRead",
    desc = "set correct filetype and commentstring for .rasi files",
    pattern = "*.rasi",
    callback = function()
        nx.set({
            filetype = "rasi",
            commentstring = "// %s",
        }, vim.bo)
    end,
}, { nested = true, create_group = "Rasi" })

nx.au({
    "BufRead",
    desc = "set appsettings.json files to be jsonc filetype",
    pattern = "appsettings*.json",
    callback = function()
        nx.set({
            filetype = "jsonc",
            commentstring = "// %s",
        }, vim.bo)
    end,
    nested = true,
}, { create_group = "AppsettingsJson" })

nx.au({
    "FileType",
    pattern = "help",
    callback = function(event)
        nx.map({ "gd", "K", buffer = event.buf, silent = true })
    end,
    nested = true,
}, { create_group = "GoToDefinitionInHelpFiles" })

-- nx.au({
--     "BufRead",
--     desc = "set correct filetype F# files",
--     pattern = { "*.fs", "*.fsx", "*.fsi" },
--     command = "set filetype=fsharp",
-- }, { create_group = "fsharp" })

-- nx.au({
--     "BufEnter",
--     desc = "set correct filetype and commentstring for polybar conf files",
--     pattern = "do",
--     callback = function()
--         nx.set({
--             filetype = "dosini",
--             commentstring = "# %s",
--         }, vim.bo)
--     end,
-- }, { create_group = "GitCommit" })

-- nx.au({
--     "FileType",
--     desc = "set filetype for llvm",
--     pattern = "lifelines",
--     command = "set filetype=llvm",
-- }, { create_group = "LLVM" })

-- Check if we need to reload the file when it changed
nx.au({
    { "FocusGained", command = "checktime" },
    { "TermClose", command = "checktime" },
    { "TermLeave", command = "checktime" },
}, { create_group = "CheckIfEditedOutside", nested = true })

-- resize splits if window got resized
nx.au({
    "VimResized",
    command = "tabdo wincmd =",
}, { nested = true, create_group = "ResizeSplits" })

-- close some filetypes with <q>
nx.au({
    "FileType",
    pattern = {
        "",
        "PlenaryTestPopup",
        "checkhealth",
        "help",
        "httpResult",
        "lspinfo",
        "man",
        "neotest-output",
        "neotest-output-panel",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        nx.map({ "q", "<cmd>close!<cr>", buffer = event.buf, silent = true })
    end,
}, { create_group = "CloseWithQ", nested = true })

-- close some filetypes with <q>
nx.au({
    "FileType",
    pattern = { "gitcommit", "help", "starter" },
    callback = function(event)
        nx.map({ "q", "<cmd>quit<cr>", buffer = event.buf, silent = true })
    end,
}, { create_group = "QuitWithQ", nested = true })

-- wrap and check for spell in text filetypes
nx.au({
    {
        "FileType",
        pattern = "gitcommit",
        callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
        end,
    },
}, { nested = true, create_group = "GitCommitGroup" })

nx.au({
    {
        "FileType",
        pattern = "help",
        callback = function()
            vim.opt_local.conceallevel = 0
        end,
    },
}, { nested = true, create_group = "GitCommitGroup" })

nx.au({
    "FileType",
    pattern = "qf",
    callback = function()
        nx.map({
            "dd",
            function()
                local currentLine = vim.fn.line(".")
                local qflist = vim.fn.getqflist()
                table.remove(qflist, currentLine)
                vim.fn.setqflist(qflist, "u")
                -- vim.cmd("silent! cfirst " .. currentLine)
                vim.cmd("silent! copen")
            end,
            buffer = vim.api.nvim_get_current_buf(),
        })
    end,
}, { nested = true, create_group = "QuickFix" })

nx.au({
    { "BufReadPost" },
    pattern = "*.{props,sln,csproj}",
    callback = function()
        require("my.dotnet")
        -- vim.g.dotnet_errors_only = true
        -- -- vim.g.dotnet_show_project_file =false
        -- vim.cmd("compiler dotnet")
    end,
}, { nested = true, create_group = "DotnetProject" })

nx.au({
    {
        "BufReadPost",
        callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local line_count = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= line_count then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
            vim.cmd("normal! zz")
        end,
    },
}, { create_group = "RememberCursorPosition", nested = true })

nx.au({
    "TextYankPost",
    pattern = "*",
    callback = function()
        vim.hl.on_yank({ timeout = 50 })
    end,
}, { nested = true, create_group = "HighlightYank" })

nx.au({
    { "BufWinEnter", "BufReadPost" },
    --  not sure these 2 are needed
    -- "FileReadPost",
    pattern = "*",
    -- manually update folds and open all folds
    callback = function()
        vim.cmd("normal! zxzR")
        vim.opt.foldlevel = 99
    end,
}, { create_group = "UpdateFolds", nested = true })

nx.au({
    "FileType",
    pattern = "xml",
    callback = function()
        vim.opt_local.isfname:prepend("\\")
        -- don't know how to do it in lua
        vim.cmd("setlocal includeexpr=tr(v:fname,'\\\\','/')")
        -- vim.opt_local.includeexpr:prepend(vim.fn.tr(vim.v.fname, [[\\\\]], "/"))
    end,
}, { nested = true, create_group = "GFWithBackslashes" })

nx.au({
    {
        "InsertEnter",
        callback = function()
            if vim.opt.relativenumber:get() and vim.opt.number:get() then
                vim.opt.relativenumber = false
            end
        end,
    },
    {
        "InsertLeave",
        callback = function()
            if not vim.opt.relativenumber:get() and vim.opt.number:get() then
                vim.opt.relativenumber = true
            end
        end,
    },
}, { create_group = "DisableRelativeNumbersInInsertMode", nested = true })

nx.au({
    { "BufReadPost", "BufWritePost", "CursorHold", "InsertLeave" },
    callback = function(args)
        pcall(vim.lsp.codelens.refresh, { bufnr = args.buf })
    end,
}, { create_group = "LspCodeLens", nested = true })
