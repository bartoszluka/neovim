local function get_git_branch_name()
    local process = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }):wait()
    local branch = vim.trim(process.stdout) or "main"
    return branch:gsub("/", "_")
end

local function get_session_name(arg_dir)
    local cwd = vim.uv.cwd()
    local dir = arg_dir or vim.fs.normalize(cwd):gsub(":", "+")
    local ok, branch = pcall(get_git_branch_name)
    if ok then
        return dir .. "__" .. branch
    else
        return dir
    end
end

require("nx").au({
    {
        "User",
        pattern = "SessionLoadPost",
        command = "windo edit|normal! zz",
    },
    {
        "User",
        pattern = "SessioncSavePre",
        callback = function()
            require("my.shada").delete_shada()
        end,
    },
}, { nested = true, create_group = "MySessions" })

return {
    enabled = false,
    "Shatur/neovim-session-manager",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    lazy = false,
    version = false,
    config = function()
        local Path = require("plenary.path")
        local config = require("session_manager.config")
        require("session_manager").setup({
            sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"), -- The directory where the session files will be saved.
            -- session_filename_to_dir = session_filename_to_dir, -- Function that replaces symbols into separators and colons to transform filename into a session directory.
            -- dir_to_session_filename = get_session_name, -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.uv.cwd()` if the passed `dir` is `nil`.

            -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below.
            autoload_mode = {
                -- config.AutoloadMode.GitBranchSession,
                config.AutoloadMode.GitSession,
                config.AutoloadMode.CurrentDir,
            },

            autosave_last_session = true, -- Automatically save last session on exit and on session switch.
            autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
            autosave_ignore_dirs = {}, -- A list of directories where the session will not be autosaved.
            autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
                "gitcommit",
                "gitrebase",
                "help",
            },
            autosave_ignore_buftypes = {}, -- All buffers of these bufer types will be closed before the session is saved.
            autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
            max_path_length = 80, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
            load_include_current = true, -- The currently loaded session appears in the load_session UI.
        })
    end,
}
