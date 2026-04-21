-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
opt.scrolloff = 8 -- lines of context
opt.cursorline = true -- enable highlighting of the current line
opt.expandtab = true -- use spaces instead of tabs
opt.number = true -- print line number
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
opt.termguicolors = true -- true color support
