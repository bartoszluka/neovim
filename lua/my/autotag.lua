local M = {}

M.rename_tag = function()
    local node = vim.treesitter.get_node({ bufnr = 0 })
    if node == nil then
        return
    end
    local to_rename = node:parent():next_sibling():child(2)
    if to_rename == nil then
        return
    end
    local start_line, start_col, end_line, end_col = to_rename:range()
    vim.api.nvim_set_current_line("2137")
end

return M
