local function should_delete(bufnr)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

    local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

    return buftype ~= "nofile" and filetype ~= ""
end

local function bufonly(force)
    local current_buffer = vim.api.nvim_get_current_buf()

    local deleted = 0
    local bufremove_exists, MiniBufremove = pcall(require, "mini.bufremove")
    vim.iter(vim.api.nvim_list_bufs())
        :filter(function(bufnr)
            return bufnr ~= current_buffer and should_delete(bufnr)
        end)
        :each(function(bufnr)
            if bufremove_exists then
                MiniBufremove.delete(bufnr, force)
            else
                vim.api.nvim_buf_delete(bufnr, { force = force, unload = true })
            end
            deleted = deleted + 1
        end)

    vim.notify(deleted .. " deleted buffer(s)", vim.log.levels.INFO)
end

return { bufonly = bufonly }
