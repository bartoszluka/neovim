return {
    "NeogitOrg/neogit",
    cmd = { "Neogit", "NeogitLog", "NeogitCommit" },
    keys = { { "<leader>gg", cmd("Neogit") } },
    config = function()
        require("neogit").setup({
            graph_style = "unicode",
            git_services = {
                -- ["ssh-source.netcompany.com"] = "https://source.netcompany.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
                ["netcompany.com"] = "https://source.netcompany.com/${owner}/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=main",
            },
            telescope_sorter = function()
                return require("telescope.sorters").get_fzy_sorter()
            end,

            initial_branch_name = "feature/",
            kind = "tab",
            integrations = { telescope = true },
            commit_editor = {
                ["<c-p>"] = "PrevMessage",
                ["<c-n>"] = "NextMessage",
                ["<c-e>"] = "Abort",
            },
        })
    end,
}
