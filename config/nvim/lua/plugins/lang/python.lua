return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "pyright", "flake8", "black", "debugpy" })
        end,
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        dependencies = {
            "mfussenegger/nvim-dap-python",
            keys = {
                { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
                { "<leader>dPc", function() require('dap-python').test_class() end,  desc = "Debug Class",  ft = "python" },
            },
            config = function()
                -- Mason経由でインストールされたdebugpyを使用
                local mason_path = vim.fn.stdpath("data") .. "/mason"
                local debugpy_path = mason_path .. "/packages/debugpy/venv/bin/python"

                -- debugpyが存在する場合はそれを使用、なければシステムのpythonを探す
                local python_path
                if vim.fn.executable(debugpy_path) == 1 then
                    python_path = debugpy_path
                elseif vim.fn.executable("python3") == 1 then
                    python_path = vim.fn.exepath("python3")
                elseif vim.fn.executable("python") == 1 then
                    python_path = vim.fn.exepath("python")
                else
                    python_path = "/usr/bin/python3"
                end

                require("dap-python").setup(python_path)
            end,
        },
    },
}
