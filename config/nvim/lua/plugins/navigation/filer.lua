return {
    {
        'lambdalisue/fern.vim',
        dependencies = {
            { 'lambdalisue/nerdfont.vim', },
            {
                'lambdalisue/fern-renderer-nerdfont.vim',
                config = function()
                    vim.g['fern#renderer'] = "nerdfont"
                end
            },
        },
        keys = {
            { "sf", ":Fern %:h -reveal=%<CR>", desc = "Open fern at current file's directory" },
        },
        config = function ()
            vim.g["fern#default_hidden"] = 1 -- shot . files
        end
    }
}
