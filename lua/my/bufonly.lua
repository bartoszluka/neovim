---@return boolean
local function should_delete(bufnr)
    if vim.fn.buflisted(bufnr) == 0 then
        return false
    end
    return true
end

local function delete_buffer(bufnr, force)
    vim.bo[bufnr].buflisted = false
    local ok, _ = pcall(vim.api.nvim_buf_delete, bufnr, { force = force, unload = true })
    return ok
end

local function bufonly(force)
    local current_buffer = vim.api.nvim_get_current_buf()

    local deleted = 0
    -- local bufremove_exists, MiniBufremove = pcall(require, "mini.bufremove")
    vim.iter(vim.api.nvim_list_bufs())
        :filter(function(bufnr)
            return bufnr ~= current_buffer and should_delete(bufnr)
        end)
        :each(function(bufnr)
            -- if bufremove_exists then
            --     MiniBufremove.delete(bufnr, force)
            -- else
            local ok = delete_buffer(bufnr, force)
            if ok then
                deleted = deleted + 1
            end
        end)

    vim.notify(deleted .. " deleted buffer(s)", vim.log.levels.INFO)
end

return { bufonly = bufonly }
