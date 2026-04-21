return {
    -- Desativa o tema padrão do LazyVim
    { "folke/tokyonight.nvim", enabled = false },

    -- Instala o token
    {
        "ThorstenRhau/token",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("token")
        end,
    },
}
