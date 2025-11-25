local function delete_shada()
    local status = 0
    for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath("data") .. "/shada", "*tmp*", false, true)) do
        if vim.tbl_isempty(vim.fn.readfile(f)) then
            status = status + vim.fn.delete(f)
        end
    end
    if status ~= 0 then
        vim.notify("Could not delete empty temporary ShaDa files.", vim.log.levels.ERROR)
        vim.fn.getchar()
    end
end

if vim.uv.os_uname().sysname:find("Windows", 1, true) ~= 1 then
    return
end

nx.au({
    "VimLeavePre",
    pattern = "*",
    callback = delete_shada,
}, { create_group = "FuckShada", nested = true, once = true })

return {
    delete_shada = delete_shada,
}
