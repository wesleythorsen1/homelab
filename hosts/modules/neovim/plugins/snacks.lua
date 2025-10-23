require("snacks").setup({
  -- Smooth scrolling - Just scroll normally, it will be smooth automatically
  scroll = { enabled = true },
  
  -- Delete buffers without messing up window layout
  -- Usage: :bd or :bdelete still work but won't close windows
  bufdelete = { enabled = true },
  
  -- Automatically optimize for large files (>1MB)
  -- Usage: Automatic - just open large files and it handles performance
  bigfile = { enabled = true },
  
  -- Dim inactive code for better focus
  -- Usage: Automatic - inactive splits/windows will be dimmed
  dim = { enabled = true },
  
  -- Open current file/repo in browser
  -- Usage: :SnacksGitBrowse or map to keymap like <leader>gb
  gitbrowse = { enabled = true },
  
  -- Floating LazyGit with proper colorscheme integration
  -- Usage: :SnacksLazygit or map to keymap like <leader>gg
  lazygit = { enabled = true },
  
  -- Better file renaming with plugin support
  -- Usage: :SnacksRename <new_name> or map to keymap like <leader>rn
  rename = { enabled = true },
  
  -- Quick scratch buffers for notes/testing
  -- Usage: :SnacksScratch to open floating scratch buffer
  scratch = { enabled = true },
  
  -- Better toggle keymaps with which-key integration
  -- Usage: Provides Snacks.toggle.* functions for creating toggles
  toggle = { enabled = true },
  
  -- Auto-highlight word under cursor and navigate references
  -- Usage: Automatic highlighting, ]r and [r to jump between references
  words = { enabled = true },
  
  -- Prettier notifications
  -- Usage: Automatic - makes vim.notify() calls look better
  notifier = { enabled = true },
  
  -- Zen mode for distraction-free coding
  -- Usage: :SnacksZen to toggle zen mode
  zen = { enabled = true },
  
  -- Faster file rendering before plugins load
  -- Usage: Automatic - files load faster, especially large ones
  quickfile = { enabled = true },
})

-- Useful keymaps for Snacks features
vim.keymap.set("n", "<leader>gb", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>sc", function() Snacks.scratch() end, { desc = "Scratch Buffer" })
vim.keymap.set("n", "<leader>zen", function() Snacks.zen() end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>rn", function() Snacks.rename() end, { desc = "Rename File" })

-- Navigate between word references
vim.keymap.set("n", "]r", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next Reference" })
vim.keymap.set("n", "[r", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev Reference" })