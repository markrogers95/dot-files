require("config.lazy")

-- set colour scheme 
vim.cmd("colorscheme kanagawa")

-- enable spell checker
vim.cmd("set spelllang=en_uk")
vim.cmd("set spell")

-- some key mappings for buffer navigation
vim.keymap.set('n', 'gn', '<cmd>bnext<cr>')
vim.keymap.set('n', 'gp', '<cmd>bprev<cr>')
vim.keymap.set('n', 'gc', '<cmd>bd<cr>')

-- note: diagnostics are not exclusive to lsp servers
-- so these can be global keybindings
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
  require('lspconfig')[server].setup({
    capabilities = lsp_capabilities,
  })
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {gopls, pyright, yamlls, vimls},
  handlers = {
    default_setup,
  },
})

require('lspconfig').yamlls.setup({})
require('lspconfig').vimls.setup({})
require('lspconfig').lua_ls.setup({
  settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        diagnostics = {
	  globals = {'vim'}
	},
      },
    },
})

local util = require('lspconfig/util')
require('lspconfig').gopls.setup({
  root_dir = function(fname)
      local gowork_or_gomod_dir = util.root_pattern('go.work', 'go.mod')(fname)
      if gowork_or_gomod_dir then
        return gowork_or_gomod_dir
      end

      local plzconfig_dir = util.root_pattern('.plzconfig')(fname)
      if plzconfig_dir and vim.fs.basename(plzconfig_dir) == 'src' then
        vim.env.GOPATH = string.format('%s:%s/plz-out/go', vim.fs.dirname(plzconfig_dir), plzconfig_dir)
        vim.env.GO111MODULE = 'off'
        return plzconfig_dir .. '/vault' -- hack to work around slow monorepo
      end

      return vim.fn.getcwd()
    end,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})

require('lspconfig').pyright.setup({
  root_dir = function()
    return vim.fn.getcwd()
  end,
  settings = {
    python = {
      analysis = {
      autoSearchPaths = true,
      diagnosticMode = 'workspace',
      useLibraryCodeForTypes = true,
      typeCheckingMode = 'off',
      extraPaths = {
        '/home/mrogers/repos/src',
        '/home/mrogers/repos/src/plz-out/gen',
       },
     },
   },
  },
})

require('lspconfig.configs').please = {
  default_config = {
    cmd = { 'plz', 'tool', 'lps' },
    filetypes = { 'please' },
    root_dir = util.root_pattern('.plzconfig'),
  },
}
require('lspconfig').please.setup({})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Enter key confirms completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl + space triggers completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, {})
vim.keymap.set('n', 'fg', builtin.live_grep, {})
vim.keymap.set('n', 'fb', builtin.buffers, {})
vim.keymap.set('n', 'fh', builtin.help_tags, {})


local api = require('nvim-tree.api')
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.keymap.set('n', 'trt', api.tree.toggle)

vim.cmd("set relativenumber")
