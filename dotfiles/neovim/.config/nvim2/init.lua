vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-- Start an additional server socket matching the nvim.PID.0 pattern for tmux-open-nvim compatibility
local runtime_dir = vim.env.XDG_RUNTIME_DIR or ("/run/user/" .. vim.fn.getenv("UID"))
local compat_sock = runtime_dir .. "/nvim." .. vim.fn.getpid() .. ".0"
if vim.fn.filereadable(compat_sock) == 0 then
  pcall(vim.fn.serverstart, compat_sock)
end

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Custom macros
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

vim.api.nvim_create_augroup("JSLogMacro", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "JSLogMacro",
  pattern = { "javascript", "typescript" },
  callback = function()
    vim.fn.setreg("l", "y$%oconsole.log('" .. esc .. "pa:', " .. esc .. "pa);" .. esc)
  end,
})

local function my_custom_function()
  print("Hello from my custom function!")
end

_G.my_custom_function = my_custom_function
-- Function to open or create a file in the specified directory
local function open_or_create_file(cmd)
  cmd = cmd or "edit"
  local target_directory = "~/personal/code/lab-trimble/"
  local cwd = vim.fn.getcwd()
  local folder_name = cwd:match("([^/]+)$")
  local file_path = target_directory .. folder_name .. ".md"

  vim.cmd(cmd .. " " .. file_path)
end
_G.open_or_create_file = open_or_create_file

vim.api.nvim_set_keymap("n", "<leader>n", "<Cmd>lua open_or_create_file()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>N", "<Cmd>lua open_or_create_file('vsplit')<CR>", { noremap = true, silent = true })

-- Check for external file changes when focusing Neovim or leaving a terminal
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Lazy plugins
-- TODO: Remove now that nerd font is available
local lazy_opts = {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
}

require("vim-options")
require("vim-keybindings")
require("lazy").setup("plugins")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
