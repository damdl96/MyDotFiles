-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugins
require("lazy").setup({
  -- Theme
  { "morhetz/gruvbox" },

  -- File explorer
  { "preservim/nerdtree" },
  { "ryanoasis/vim-devicons" },

  -- Treesitter
  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      -- Parsers always kept installed
      ensure_installed = {
        "yaml", "bash", "lua", "vim", "vimdoc",
        "json", "ruby",
      },
      -- Fetch a missing parser automatically when a filetype is opened
      -- (needs the `tree-sitter` CLI on PATH)
      auto_install = true,
      -- Turn highlighting on by default for every buffer
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.config").setup(opts) -- Note: 'config', not 'configs'
    end,
  },
  -- Neovim Store
  {
    "alex-popov-tech/store.nvim",
    dependencies = {
      {
        "OXY2DEV/markview.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
          experimental = {
            check_rtp = false, -- silence runtime-path message
          },
        },
      },
    },
  },

  -- Fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
        },
      })
    end,
  },

  -- Indentation guides
  { "vim-scripts/indentLine.vim" },

  -- Git
  { "zivyangll/git-blame.vim" },
  { "airblade/vim-gitgutter" },

  -- React / JS / TS syntax
  { "pangloss/vim-javascript" },
  { "leafgarland/typescript-vim" },
  { "peitalin/vim-jsx-typescript" },
  { "styled-components/vim-styled-components", branch = "main" },

  -- Statusline
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },

  -- LSP + Completion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- Mason for installing servers
      require("mason").setup()

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- -----------------------------
      -- Override "Go to Definition" to open in a new tab
      -- -----------------------------
      local function open_location_in_new_tab(location, encoding)
        if not location then return end

        -- Convert LocationLink -> Location if needed
        if location.targetUri and not location.uri then
          location = {
            uri = location.targetUri,
            range = location.targetSelectionRange or location.targetRange,
          }
        end

        -- Open new tab and jump
        vim.cmd("tabnew")
        vim.lsp.util.jump_to_location(location, encoding or "utf-8")
      end

      local function definition_handler(err, result, ctx, _)
        if err then
          vim.notify("LSP: Error finding definition: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        if not result or vim.tbl_isempty(result) then
          vim.notify("LSP: No definition found", vim.log.levels.WARN)
          return
        end

        local encoding = "utf-8"
        if ctx and ctx.client_id then
          local client = vim.lsp.get_client_by_id(ctx.client_id)
          encoding = (client and client.offset_encoding) or encoding
        end

        if vim.tbl_islist(result) then
          open_location_in_new_tab(result[1], encoding)
        else
          open_location_in_new_tab(result, encoding)
        end
      end

      -- Set LSP handler globally
      vim.lsp.handlers["textDocument/definition"] = definition_handler

      -- Override vim.lsp.buf.definition so keymaps/context menus use it
      vim.lsp.buf.definition = function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/definition", params, definition_handler)
      end

      -- Map gd to new-tab definition
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })

      -- -----------------------------
      -- LSP server setups using vim.lsp.config
      -- -----------------------------
      -- Lua
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      }

      -- TypeScript / JavaScript
      vim.lsp.config.ts_ls = {
        capabilities = capabilities,
      }

      -- Ruby (solargraph)
      vim.lsp.config.solargraph = {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          if vim.bo[bufnr].filetype ~= "ruby" then
            client.stop()
            return
          end
          client.config.flags = client.config.flags or {}
          client.config.flags.debounce_text_changes = 500
        end,
        settings = {
          solargraph = {
            diagnostics = true,
            completion = true,
            formatting = true,
            max_files = 0,
          },
        },
      }

      -- Enable the LSP servers
      vim.lsp.enable({ "lua_ls", "ts_ls", "solargraph" })

      -- -----------------------------
      -- Completion setup
      -- -----------------------------
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
          { name = "luasnip" },
        }),
      })
    end,
  },
})

