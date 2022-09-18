-- Set leader key to space
vim.cmd([[let mapleader = "\<Space>"]])
-- Load packer.nvim
vim.cmd([[packadd packer.nvim]])
require('packer').startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')
    -- Catppuccin theme
    use({ 'catppuccin/nvim', as = 'catppuccin' })
    -- nvim-tree file tree plugin
    use({
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons',
            opt = true,
        },
        config = function()
            require('nvim-tree').setup({
                -- Recommended for compatibility with projects.nvim
                sync_root_with_cwd = true,
                respect_buf_cwd = true,
                update_focused_file = {
                    enable = true,
                    update_root = true,
                },
            })
        end,
    })
    -- null-ls provides formatting
    use({
        'jose-elias-alvarez/null-ls.nvim',
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            local null_ls = require('null-ls')
            null_ls.setup({
                sources = {

                    null_ls.builtins.formatting.clang_format,
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.cmake_format,
                },
            })
        end,
    })
    -- Project management with projects.nvim
    use({
        'ahmedkhalf/project.nvim',
        config = function()
            require('project_nvim').setup({
                -- Detect purely by file patterns
                detection_methods = { 'pattern' },
                -- CMake project files, git files, clang files
                patterns = {
                    'CMakeLists.txt',
                    '.clang-format',
                    '.gitignore',
                    '=.git',
                    'compile_commands.json',
                },
                show_hidden = true,
            })
        end,
    })
    -- Configure nvim lsp
    use({
        'neovim/nvim-lspconfig',
        config = function()
            -- Required for completions
            local capabilities = require('cmp_nvim_lsp').update_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            local lspconfig = require('lspconfig')
            -- CMake ls
            lspconfig['cmake'].setup({
                capabilities = capabilities,
            })
            -- Bash ls
            lspconfig['bashls'].setup({
                capabilities = capabilities,
            })
            -- C/C++ ls
            lspconfig['clangd'].setup({
                capabilities = capabilities,
                cmd = {
                    'clangd',
                    -- Use clang tidy
                    '--clang-tidy',
                },
            })
            -- Lua ls
            lspconfig['sumneko_lua'].setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file('', true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })
        end,
    })
    -- Snippets
    use('hrsh7th/vim-vsnip')
    -- Autocompletion with LSP
    use({
        'hrsh7th/nvim-cmp',
        config = function()
            vim.cmd([[set completeopt=menu,menuone,noselect]])
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn['vsnip#anonymous'](args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    -- LSP source
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                    -- Snippets source
                    { name = 'vsnip' },
                }),
            })
            -- `/` cmdline setup.
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' },
                },
            })
            -- `:` cmdline setup.
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' },
                }, {
                    { name = 'cmdline' },
                }),
            })
        end,
    })
    use('hrsh7th/cmp-vsnip')
    use('hrsh7th/cmp-nvim-lsp')
    -- Telescope fuzzy finder
    use({
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            -- Load projects extension
            require('telescope').load_extension('projects')
        end,
    })

    -- Treesitter
    use({
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })
        end,
        config = function()
            require('nvim-treesitter.configs').setup({
                -- Use treesitter syntax for bash, c, cpp and lua
                ensure_installed = { 'bash', 'c', 'cpp', 'lua' },
                sync_install = false,
                auto_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    })
    -- Autopairs
    use({
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup({})
        end,
    })
    -- Lualine statusline
    use({
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'catppuccin',
                },
            })
        end,
    })
end)

local opts = { noremap = true, silent = true }

-- Unmap q,t,<Space>
vim.api.nvim_set_keymap('n', 't', '<Nop>', opts)
vim.api.nvim_set_keymap('n', 'q', '<Nop>', opts)
vim.api.nvim_set_keymap('n', '<Space>', '<Nop>', opts)

-- <leader>w in normal mode closes buffer
vim.api.nvim_set_keymap('n', '<Leader>w', '<Cmd>BufferClose<CR>', opts)
-- <leader>d in normal mode jumps to definition
vim.keymap.set('n', '<Leader>d', function()
    local function on_list_open_list(options)
        vim.fn.setloclist(0, {}, ' ', options)
        vim.api.nvim_command('lopen')
    end

    vim.lsp.buf.definition({ reuse_win = false, on_list = on_list_open_list })
end)
-- <leader>F in normal mode formats file
vim.keymap.set('n', '<Leader>F', function()
    vim.lsp.buf.format({ timeout_ms = 3000 })
end)
-- <leader>t in normal mode toggles file tree
vim.keymap.set('n', '<Leader>t', function()
    require('nvim-tree').toggle(false, false)
end)
-- <leader>f in normal mode opens Telescope fzf
vim.api.nvim_set_keymap('n', '<Leader>f', '<Cmd>Telescope<CR>', opts)
-- Catppuccin mocha colorscheme
vim.g.catppuccin_flavour = 'mocha' -- latte, frappe, macchiato, mocha
vim.cmd([[colorscheme catppuccin]])
-- Hybrid line numbers
vim.opt.relativenumber = true
vim.opt.number = true
-- Don't show mode in command bar
vim.opt.showmode = false
-- Highline line cursor is on
vim.opt.cursorline = true
-- Indent behavior is 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.cindent = true
-- Show <Leader> timeout and set timeoutlen to 500ms
vim.opt.showcmd = true
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
-- Make background transparent
--vim.cmd[[:hi normal guibg=000000]]
