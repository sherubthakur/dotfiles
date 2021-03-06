require('lualine').setup {
    options = {
        section_separators = {'', ''},
        component_separators = {'', ''},
        -- Hack : This is defined in the nvim/index.nix (String interpolation)
        theme = statusline_theme,
        iconsEnabled = true
    },
    sections = {
        lualine_a = {{'mode', upper = true}},
        lualine_b = {'filename'},
        lualine_c = {{'diagnostics', sources = {'nvim_lsp'}}},
        lualine_x = {'diff', 'branch'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    }
}
