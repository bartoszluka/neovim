local M = {}

local function info(text)
    vim.notify(text, vim.log.levels.INFO)
end

local rename_tag = function()
    info("---")
    local bufnr = vim.api.nvim_get_current_buf()
    local node = vim.treesitter.get_node({ bufnr = bufnr })
    if node == nil then
        info("node at cursor is nil")
        return
    end
    local node_text
    local parent
    if node:type() == "STag" then
        parent = node
        node_text = vim.treesitter.get_node_text(node:child(1), bufnr)
    elseif node:type() == "Name" then
        parent = node:parent()
        node_text = vim.treesitter.get_node_text(node, bufnr)
    else
        info("unexpected node type " .. node:type())
        return
    end
    if parent == nil then
        info("parent is nil")
        return
    end
    info("parent: " .. parent:sexpr())
    local sibling = parent
    while sibling ~= nil and sibling:type() ~= "Name" do
        sibling = sibling:next_sibling()
        info("current sibling: " .. sibling:sexpr())
    end
    if sibling == nil then
        info("sibling is nil")
        return
    end

    local to_rename = sibling
    -- if to_rename == nil then
    --     info("node to rename is nil")
    --     return
    -- end
    local start_line, start_col, end_line, end_col = to_rename:range()
    if start_line ~= end_line then
        info("edit is not on the same line")
        return
    end
    local line = vim.fn.getline(start_line + 1)
    local newline = line:sub(0, start_col) .. node_text .. line:sub(end_col + 1, string.len(line))
    vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, true, { newline })
end

M.rename_tag = rename_tag

M.attach_to_buffer = function(bufnr)
    if bufnr == nil or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    nx.au({
        { "TextChanged", "InsertLeave" },
        callback = rename_tag,
        create_group = "MyAutoTag",
        buffer = bufnr,
        desc = "auto rename closing tag",
    })
end

return M
