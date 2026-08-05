-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
  {
    "ryanoasis/vim-devicons",
    -- vim-devicons must be sourced after NERDTree, since it hooks in through
    -- NERDTree's `nerdtree_plugin/` runtime directory.
    dependencies = { "preservim/nerdtree" },
    config = function()
      -- devicons attaches file glyphs by registering listeners on
      -- g:NERDTreePathNotifier. That registration is missing from the
      -- notifier's map by the time NERDTree builds its paths, so no glyphs are
      -- ever attached and the tree renders bare filenames. Re-register once at
      -- startup; the `index()` guard keeps a glyph from being added twice if
      -- the original registration did survive.
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("DeviconsNerdTreeFix", { clear = true }),
        once = true,
        callback = function()
          if vim.fn.exists("g:NERDTreePathNotifier") == 0
            or vim.fn.exists("*NERDTreeWebDevIconsRefreshListener") == 0
          then
            return
          end

          vim.cmd([[
            for ev in ['init', 'refresh', 'refreshFlags']
              if index(g:NERDTreePathNotifier.GetListenersForEvent(ev), 'NERDTreeWebDevIconsRefreshListener') < 0
                call g:NERDTreePathNotifier.AddListener(ev, 'NERDTreeWebDevIconsRefreshListener')
              endif
            endfor
          ]])
        end,
      })
    end,
  },

  -- Treesitter
  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    -- The `master` branch is archived; the rewrite lives on `main`. Pin it
    -- explicitly, otherwise lazy.nvim leaves an existing clone on master and
    -- `nvim-treesitter.config` (main only) fails to resolve.
    branch = "main",
    lazy = false, -- upstream: this plugin does not support lazy-loading
    build = ":TSUpdate",
    -- No `opts` table here: on `main` the module system is gone, so setup()
    -- accepts only `install_dir`. Parsers and highlighting are driven below.
    config = function()
      local ts = require("nvim-treesitter")

      local function installed(lang)
        return vim.tbl_contains(ts.get_installed("parsers"), lang)
      end

      local function start(buf, lang)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.treesitter.start, buf, lang)
          end
        end)
      end

      -- Parsers always kept installed (replaces `ensure_installed`)
      local missing = vim.tbl_filter(function(lang)
        return not installed(lang)
      end, {
        "yaml", "bash", "lua", "vim", "vimdoc",
        "json", "ruby",
      })
      if #missing > 0 then
        ts.install(missing)
      end

      -- Turn highlighting on for every buffer whose language has a parser
      -- (replaces `highlight.enable`), fetching a missing parser on the fly
      -- when one is available (replaces `auto_install`; needs the
      -- `tree-sitter` CLI on PATH).
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
            return
          end

          if installed(lang) then
            start(ev.buf, lang)
          elseif vim.tbl_contains(ts.get_available(), lang) then
            ts.install({ lang }):await(function()
              start(ev.buf, lang)
            end)
          end
        end,
      })
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
  -- indentLine drew its guides with `syntax match ... conceal`, which the
  -- treesitter highlighter destroys: it does `vim.bo.syntax = ''` on start, so
  -- the guides vanished on open and again after every reload (e.g. `git pull`).
  -- indent-blankline uses extmarks via a decoration provider, so it is redrawn
  -- on every screen update and survives both.
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "¦" },
      scope = { enabled = false },
    },
  },

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
      -- "Go to Definition" (gd) opens in a new tab
      -- -----------------------------
      -- `on_list` hands us quickfix-style items that Neovim has already
      -- normalized (LocationLink -> Location, offset encoding applied), so no
      -- handler override or manual conversion is needed.
      local function definition_in_new_tab(result)
        local items = result.items
        if not items or vim.tbl_isempty(items) then
          vim.notify("LSP: No definition found", vim.log.levels.WARN)
          return
        end

        vim.cmd("tabnew")

        if #items == 1 then
          local item = items[1]
          vim.cmd.edit(vim.fn.fnameescape(item.filename))
          vim.api.nvim_win_set_cursor(0, { item.lnum, math.max(item.col - 1, 0) })
        else
          -- Several candidates: let the location list act as the picker
          vim.fn.setloclist(0, {}, " ", result)
          vim.cmd.lopen()
        end
      end

      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition({ on_list = definition_in_new_tab })
      end, { noremap = true, silent = true })

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

