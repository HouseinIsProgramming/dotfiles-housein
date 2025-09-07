return {
  "SmiteshP/nvim-navic",
  lazy = true,
  opts = {
    lsp = {
      auto_attach = false,
      preference = nil,
    },
    highlight = false,
    separator = " ▸ ",
    depth_limit = 0,
    depth_limit_indicator = "..",
    safe_output = true,
    lazy_update_context = false,
    click = false,
  },
  config = function(opts)
    require("nvim-navic").setup(opts)

    -- Set up winbar to always show filename, with navic when available
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
      callback = function()
        local navic = require("nvim-navic")
        local filename = vim.fn.expand("%:t")

        if filename == "" then filename = "[No Name]" end

        local winbar_content = " " .. filename

        if navic.is_available() then
          local location = navic.get_location()
          if location ~= "" then winbar_content = winbar_content .. " ▸ " .. location end
        end

        vim.opt_local.winbar = winbar_content
      end,
    })
  end,
}
