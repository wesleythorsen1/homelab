local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
  -- Format keymap removed - now handled by conform.nvim

  -- Normal mode: comment current line with Ctrl-k then c
  vim.keymap.set("n", "<C-k>c", function()
    require("Comment.api").toggle.linewise.current()
  end, opts)

  -- Visual mode: comment selection with Ctrl-k then c
  vim.keymap.set("v", "<C-k>c", function()
    local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    require("Comment.api").toggle.linewise(vim.fn.visualmode())
  end, opts)
end

-- Minimal LSP setup
local lspconfig = require("lspconfig")

-- TypeScript / JavaScript
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    }
  }
})

-- Nix
lspconfig.nixd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
