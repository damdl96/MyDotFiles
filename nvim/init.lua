-- Leader must be set before lazy loads
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Load lazy.nvim (plugins)
require("config.lazy")

-- Load legacy Vimscript configs (resolved relative to this config dir,
-- so the setup works regardless of where the repo is cloned)
local config_dir = vim.fn.stdpath("config")
vim.cmd("source " .. config_dir .. "/general/settings.vim")
vim.cmd("source " .. config_dir .. "/keys/mappings.vim")
