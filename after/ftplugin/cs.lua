vim.api.nvim_create_user_command("DotnetBuild", function()
    local sln_file = vim.fs.find(function(name, _)
        return name:match(".*sln$")
    end, {
        limit = math.huge,
        upward = true,
        stop = "nc",
        type = "file",
        path = vim.fs.dirname(vim.fn.expand("%")),
    })[1]
    vim.system({ "dotnet", "build", sln_file, "-consoleloggerparameters:ErrorsOnly" }, { text = true }, function(out)
        vim.schedule(function()
            local namespace = vim.api.nvim_create_namespace("dotnet")
            if out.code == 0 or out.stdout == nil then
                vim.notify("no errors", vim.log.levels.INFO)
                return
            end

            local lines = vim.split(out.stdout, "\n", { trimempty = true })
            vim.print(lines)
            local diagnostics = vim.iter(lines)
                :map(function(line)
                    local pattern = "(.+)%((%d+),(%d+)%): (%w+) (%w+%d+): (.+) %[(.+)%]"
                    local groups = { "source", "lnum", "col", "severity", "code", "message", "project" }
                    return vim.diagnostic.match(line, pattern, groups, {})
                end)
                :totable()
            -- vim.diagnostic.set(namespace, 0, diagnostics)
            -- vim.diagnostic.setqflist()
        end)
    end)
end, {})

