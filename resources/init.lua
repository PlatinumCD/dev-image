------------------------------------------------------------
-- Core editor options (PRESERVED)
------------------------------------------------------------
vim.o.mouse = ""
vim.o.guicursor = "n-v-c:block,i:block"

vim.o.number = true
vim.o.numberwidth = 4
vim.o.signcolumn = "yes:1"

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.cursorline = true

vim.opt.shell = "/bin/bash"
vim.o.pumheight = 4

------------------------------------------------------------
-- lazy.nvim bootstrap
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

  -- Utilities
  { "nvim-lua/plenary.nvim" },

  -- Treesitter (syntax + folding)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "bash",
        "markdown",
        "markdown_inline",
        "html",
      },
      highlight = { enable = true },
    },
  },

  -- Native LSP
  { "neovim/nvim-lspconfig" },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- Modern C++ highlighting
  { "bfrg/vim-cpp-modern" },

  -- Markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Quarto / Literate programming
  {
    "quarto-dev/quarto-nvim",
    dependencies = { "jmbuhr/otter.nvim" },
  },

})

------------------------------------------------------------
-- Colorscheme (REQUIRED)
------------------------------------------------------------
pcall(vim.cmd, "colorscheme yitzchok-contrast")

------------------------------------------------------------
-- LSP: clangd
------------------------------------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--background-index" },
})

vim.lsp.enable("clangd")

------------------------------------------------------------
-- Autocomplete (nvim-cmp)
------------------------------------------------------------
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
  }),

  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

------------------------------------------------------------
-- Treesitter folding (PRESERVED)
------------------------------------------------------------
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 9
vim.opt.foldnestmax = 1

------------------------------------------------------------
-- Markdown rendering
------------------------------------------------------------
require("render-markdown").setup({})

------------------------------------------------------------
-- Quarto / Otter (PRESERVED)
------------------------------------------------------------
require("otter").setup({})

require("quarto").setup({
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = "curly",
    languages = { "r", "python", "julia", "bash", "html" },
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = true,
    default_method = "slime",
    never_run = { "yaml" },
  },
})

------------------------------------------------------------
-- Completion menu UI (PRESERVED)
------------------------------------------------------------
vim.cmd([[
  highlight Pmenu ctermbg=darkblue guibg=#2E3440
  highlight PmenuSel ctermbg=blue guibg=#3B4252 guifg=#FFFFFF
  highlight PmenuSbar ctermbg=darkblue guibg=#2E3440
  highlight PmenuThumb ctermbg=blue guibg=#4C566A
]])

