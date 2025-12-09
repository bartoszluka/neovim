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
        ["Directory.*%.props"] = "xml",
        [".*%.component%.html"] = "htmlangular",
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

nx.au({
    { "BufReadPost" },
    callback = function()
        vim.opt.foldmethod = "indent"
        vim.opt.foldenable = false

        function MyFoldtext()
            local lines_folded = vim.v.foldend - vim.v.foldstart
            local text_lines = " lines"

            if lines_folded == 1 then
                text_lines = " line"
            end

            local fold_start_line = vim.fn.getline(vim.v.foldstart)
            -- local indent_size = vim.fn.shiftwidth()
            -- local indent = string.rep(" ", indent_size)
            -- local number_of_indents = tonumber(vim.treesitter.foldexpr()) ---@as number
            -- if not number_of_indents then
            --     number_of_indents = 1
            -- end
            -- return string.rep(indent, number_of_indents) .. lines_folded .. text_lines

            return fold_start_line .. " + " .. lines_folded .. text_lines
        end
        vim.opt.foldtext = "v:lua.MyFoldtext()"
    end,
}, { create_group = "Folds", nested = true })

--- @param str string|nil
--- @return boolean
local function is_empty(str)
    return str == "" or str == nil
end

--- @param client vim.lsp.Client
--- @param refs vim.quickfix.entry[]
--- @return vim.quickfix.entry[]
local function remove_declaration(client, refs)
    local win = vim.api.nvim_get_current_win()
    local position = vim.lsp.util.make_position_params(win, client.offset_encoding)

    local response, client_error = client:request_sync("textDocument/definition", position, 1000)
    if client_error ~= nil then
        vim.notify(vim.inspect(client_error), vim.log.levels.ERROR)
        return refs
    end
    if response ~= nil and response.err ~= nil then
        vim.notify(vim.inspect(response.err), vim.log.levels.ERROR)
        return refs
    end
    if response == nil then
        return refs
    end

    local def_positions = response.result ---@as lsp.Position
    local filtered = vim.iter(refs)
        :filter(function(item)
            local ref_position = item.user_data ---@as lsp.Position
            return not vim.tbl_contains(def_positions, function(definition_position)
                return vim.deep_equal(definition_position, ref_position)
            end, { predicate = true })
        end)
        :totable()
    return filtered
end

--- @param opts vim.lsp.LocationOpts.OnList
--- @param references_of string
--- @param client vim.lsp.Client
local function my_references(opts, references_of, client)
    local refs = opts.items ---@as vim.quickfix.entry[]

    if client.name == "roslyn" then
        refs = remove_declaration(client, refs)
    end

    if #refs == 0 then
        vim.notify("no references", vim.log.levels.INFO)
        return
    end

    local option = " " -- push to the quickfix stack
    vim.fn.setqflist(refs, option)
    vim.fn.setqflist({}, "a", { title = ("references of `%s`"):format(references_of) })
    if #refs == 1 then
        vim.cmd("silent! cfirst")
    else
        vim.cmd("silent! copen")
    end
end

local function do_rename(new_name)
    if is_empty(new_name) then
        return
    end

    local split = vim.split(new_name, " ", { plain = true, trimempty = true })
    if #split == 1 then
        return vim.lsp.buf.rename(new_name)
    end

    -- more than one word, convert to camelCase
    local first_word = split[1]:lower()
    local capitalized = vim.iter(split)
        :skip(1)
        :map(function(word)
            local first_char = string.sub(word, 1, 1)
            local rest = string.sub(word, 2)
            return first_char:upper() .. rest
        end)
        :join("")
    return vim.lsp.buf.rename(first_word .. capitalized)
end

--- @type string|nil
_G.last_new_name = nil

--- wraps rename so that it is dot-repeatable
_G.my_rename_wrapped = function(name)
    if not name then
        last_new_name = nil
        vim.go.operatorfunc = "v:lua.global_my_rename"
        return "g@l"
    end
    do_rename(name)
end

_G.global_my_rename = function()
    if is_empty(last_new_name) then
        vim.ui.input({ prompt = "new name: " }, function(new_name)
            if is_empty(new_name) then
                return
            end
            last_new_name = new_name
            do_rename(last_new_name)
        end)
        return
    end

    do_rename(last_new_name)
end

nx.au({
    "LspAttach",
    callback = function(event)
        local bufnr = event.buf
        nx.map({
            {
                "K",
                function()
                    vim.lsp.buf.hover({ border = "single" })
                end,
                desc = "hover",
            },
            { "gd", vim.lsp.buf.definition, desc = "go to definition" },
            { "gtd", vim.lsp.buf.type_definition, desc = "go to type definition" },
            { "<leader>a", vim.lsp.buf.code_action, { "n", "v" }, desc = "code action" },
            { "gi", vim.lsp.buf.implementation, desc = "go to implementation" },
            {
                "grr",
                function()
                    ---@type lsp.ReferenceContext
                    local context = { includeDeclaration = false }
                    local word_under_cursor = vim.fn.expand("<cword>")
                    vim.lsp.buf.references(context, {
                        on_list = function(opts)
                            local client = vim.lsp.get_client_by_id(event.data.client_id)
                            if not client then
                                return
                            end
                            my_references(opts, word_under_cursor, client)
                        end,
                    })
                end,
                desc = "go to references",
            },
            { "gra", vim.lsp.buf.code_action, desc = "code action" },
            {
                "grn",
                my_rename_wrapped,
                expr = true,
                desc = "rename",
            },
            { "gh", vim.diagnostic.open_float, desc = "open diagnostic" },
            { "<leader>ha", vim.lsp.codelens.run, desc = "code lens" },
        }, { buffer = bufnr })
    end,
}, { nested = true, create_group = "LspKeymaps" })
