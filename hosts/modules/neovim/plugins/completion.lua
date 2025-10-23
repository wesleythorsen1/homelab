local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),                 -- manually trigger completion
    ["<CR>"]      = cmp.mapping.confirm({ select = true }), -- accept selected
    ["<Tab>"]     = cmp.mapping.select_next_item(),
    ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP completions
    { name = "luasnip" },  -- snippets
    { name = "buffer" },   -- words in current buffer
    { name = "path" },     -- filesystem paths
  }),
})
