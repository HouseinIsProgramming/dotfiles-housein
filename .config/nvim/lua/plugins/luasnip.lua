return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local luasnip = require("luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()
    
    luasnip.config.setup({
      history = true,
      delete_check_events = "TextChanged",
    })
  end,
}