return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = { "ConformInfo" },
        keys = {
            {
                "<space>f",
                function()
                    require("conform").format({ async = true, lsp_fallback = true })
                end,
                mode = "n",
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                lua = { "stylua" },
                go = { "goimports", "gofumpt" },
                sh = { "shfmt" },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "ruff" })
        end,
    },
}
