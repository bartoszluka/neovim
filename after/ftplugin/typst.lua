nx.cmd({
    "OpenPdf",
    function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath:match("%.typ$") then
            local pdf_path = filepath:gsub("%.typ$", ".pdf")
            vim.print(pdf_path)
            vim.system({ "start", pdf_path })
        end
    end,
    desc = "open typst generated pdf",
})
