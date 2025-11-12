local function delete_shada()
    local status = 0
    for _, f in ipairs(vim.fn.globpath(vim.fn.stdpath("data") .. "/shada", "*tmp*", false, true)) do
        status = status + vim.fn.delete(f)
    end
    if status == 0 then
        vim.print("Successfully deleted all temporary shada files")
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
