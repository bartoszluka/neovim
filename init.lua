vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.g.editorconfig = true

-- Native plugins
-- cmd.filetype("plugin", "indent", "on")
-- cmd.packadd("cfilter") -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
-- vim.g.sqlite_clib_path = require("luv").os_getenv("LIBSQLITE")

_G.cmd = function(command)
    return "<cmd>" .. command .. "<CR>"
end

require("my.powershell")
require("config.lazy")
require("my.autocommands")
require("my.settings")
require("my.keymaps")
require("my.commands")
