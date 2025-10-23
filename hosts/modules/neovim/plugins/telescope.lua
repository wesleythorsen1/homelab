local telescope = require("telescope")
local builtin = require("telescope.builtin")

vim.g.mapleader = " "

-- Safe default setup
telescope.setup({})

-- Enable the fzf-native sorter
telescope.load_extension('fzf')

vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
