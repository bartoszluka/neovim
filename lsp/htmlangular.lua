local angularls_path = vim.fs.dirname(vim.fn.exepath("ngserver"))

local cmd = {
    "ngserver",
    "--stdio",
    "--tsProbeLocations",
    table.concat({
        angularls_path,
        vim.uv.cwd(),
    }, ","),
    "--ngProbeLocations",
    table.concat({
        angularls_path .. "/node_modules/@angular/language-server",
        vim.uv.cwd(),
    }, ","),
}

return {
    cmd = cmd,
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end,
}
