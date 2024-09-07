vim.o.mouse = ""
vim.o.guicursor = "n-v-c:block,i:block"

vim.o.number = true
vim.o.numberwidth = 4
vim.o.signcolumn = 'yes:1'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.cursorline = true

vim.opt.shell = "/bin/bash"

-- Plugin section with vim-plug
vim.cmd [[
  call plug#begin('~/.vim/plugged')
  Plug 'bfrg/vim-cpp-modern'
  Plug 'rainglow/vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  call plug#end()
]]

vim.cmd [[
  highlight Pmenu ctermbg=darkblue guibg=#2E3440
  highlight PmenuSel ctermbg=blue guibg=#3B4252 guifg=#FFFFFF
  highlight PmenuSbar ctermbg=darkblue guibg=#2E3440
  highlight PmenuThumb ctermbg=blue guibg=#4C566A
]]


vim.g.coc_global_extensions = {'coc-clangd'}
vim.o.pumheight = 4

-- Tab to confirm the selection and close the autocomplete window
vim.api.nvim_set_keymap('i', '<TAB>', 'pumvisible() ? coc#pum#confirm() : "\\<TAB>"', {expr = true, noremap = true, silent = true})
vim.api.nvim_set_keymap('i', '<S-TAB>', 'pumvisible() ? "\\<C-p>" : "\\<S-TAB>"', {expr = true, noremap = true, silent = true})
