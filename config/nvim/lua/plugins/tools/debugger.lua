return {
    -- core debugger ui
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- fancy UI for the debugger
            {
                "rcarriga/nvim-dap-ui",
                -- stylua: ignore
                keys = {
                    { "<space>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
                    { "<space>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
                },
                opts = {},
                config = function(_, opts)
                    -- setup dap config by VsCode launch.json file
                    -- require("dap.ext.vscode").load_launchjs()
                    local dap = require("dap")
                    local dapui = require("dapui")
                    dapui.setup(opts)
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        dapui.open({})
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close({})
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close({})
                    end
                end,
            },

            -- virtual text for the debugger
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },

            -- which key integration
            {
                "folke/which-key.nvim",
                optional = true,
                opts = {
                    defaults = {
                        ["<leader>d"] = { name = "+debug" },
                    },
                },
            },

            -- mason.nvim integration
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = "mason.nvim",
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    -- Makes a best effort to setup the various debuggers with
                    -- reasonable debug configurations
                    automatic_installation = true,

                    -- You can provide additional configuration to the handlers,
                    -- see mason-nvim-dap README for more information
                    handlers = {},

                    -- You'll need to check that you have the required things installed
                    -- online, please don't ask me how to install them :)
                    ensure_installed = {
                        -- Update this to ensure that you have the debuggers for the langs you want
                    },
                },
            },
        },

        -- stylua: ignore
        keys = {
            { "<space>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<space>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
            { "<space>dc", function() require("dap").continue() end,                                             desc = "Continue" },
            { "<space>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
            { "<space>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
            { "<space>dg", function() require("dap").goto_() end,                                                desc = "Go to line (no execute)" },
            { "<space>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
            { "<space>dj", function() require("dap").down() end,                                                 desc = "Down" },
            { "<space>dk", function() require("dap").up() end,                                                   desc = "Up" },
            { "<space>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
            { "<space>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
            { "<space>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
            { "<space>dp", function() require("dap").pause() end,                                                desc = "Pause" },
            { "<space>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
            { "<space>ds", function() require("dap").session() end,                                              desc = "Session" },
            { "<space>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
            { "<space>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        },
        config = function ()
            require("dap").setup({})
        end
    }
}
