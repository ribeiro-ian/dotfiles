-- Colorscheme aliases map: alias => nvim colorscheme
local aliases = {
	["Claude"] = "token",
	-- add colorschemes
}

local ok, colorscheme = pcall(require, "config.theme")
local function get_colorscheme()
	if not ok then
		return "token"
	end
	return aliases[colorscheme] or colorscheme
end

return {
	-- ──── Colorschemes ────
	-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
	{ "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} }, -- Default
	{ "ThorstenRhau/token", lazy = false, priority = 1000 }, -- Claude color palette

	-- ──── Load Current Colorscheme ────
	-- Plugin to load current colorscheme after all colorschemes loaded
	{
		dir = vim.fn.stdpath("config"),
		name = "colorscheme-loader",
		lazy = false,
		priority = 500,
		config = function()
			vim.cmd.colorscheme(get_colorscheme())
		end,
	},
	-- Highlight todo, notes, etc in comments
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		---@module 'todo-comments'
		---@type TodoOptions
		---@diagnostic disable-next-line: missing-fields
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({
				-- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
				mappings = {
					around_next = "aa",
					inside_next = "ii",
				},
				n_lines = 500,
			})

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/nvim-mini/mini.nvim
		end,
	},

	-- Noice: cmdline popup centered
	{
		"folke/noice.nvim",
		event = "VimEnter",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			cmdline = { view = "cmdline_popup" },
			messages = { enabled = true },
			popupmenu = { enabled = true },
		},
	},
}
