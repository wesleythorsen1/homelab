-- General keymaps that are NOT specific to a plugin live here

-- File navigation
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Movement improvements
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")  -- Move selected lines down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")  -- Move selected lines up

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Keep cursor centered during searches
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Better paste behavior
vim.keymap.set("x", "<leader>p", "\"_dP")  -- Don't lose clipboard when pasting over

-- System clipboard shortcuts
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")  -- Copy whole line to system clipboard

-- Quick save and quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")  -- Quick save
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>")  -- Quick quit
vim.keymap.set("n", "<leader>x", "<cmd>x<CR>")  -- Save and quit

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Window resizing
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Buffer navigation
vim.keymap.set("n", "<S-l>", ":bnext<CR>")     -- Next buffer
vim.keymap.set("n", "<S-h>", ":bprevious<CR>") -- Previous buffer
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>") -- Delete buffer

-- Clear search highlighting
vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>")

-- Better terminal navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")

-- Toggle terminal
vim.keymap.set("n", "<leader>t", ":terminal<CR>")

-- Quick fix navigation
vim.keymap.set("n", "<leader>j", ":cnext<CR>")
vim.keymap.set("n", "<leader>k", ":cprev<CR>")

-- Select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")
