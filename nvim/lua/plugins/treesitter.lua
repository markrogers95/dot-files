 return {
    'nvim-treesitter/nvim-treesitter', -- Highlight, edit, and navigate code
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'comment',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'html',
        'java',
        'javascript',
        'json',
        'lua',
        'markdown',
        'make',
        'perl',
        'php',
        'promql',
        'proto',
        'python',
        'query',
        'regex',
        'ruby',
        'rust',
        'scheme',
        'sql',
        'ssh_config',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },

      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ['iv'] = '@literal_value.inner',
            ['av'] = '@literal_value.outer',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
      { 'nvim-treesitter/nvim-treesitter-context', opts = {} },
    },
}
