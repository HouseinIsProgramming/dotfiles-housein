return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      -- Load LazyVim types when the `LazyVim` word is found
      { path = "LazyVim", words = { "LazyVim" } },
      -- Always load the LazyVim library
      "LazyVim",
      -- Only load the lazyvim library when the `LazyVim` global is found
      { path = "lazy.nvim", words = { "LazyVim" } },
      -- Load the wezterm types when the `wezterm` module is required
      -- Needs `justinsgithub/wezterm-types` to be installed
      { path = "wezterm-types", mods = { "wezterm" } },
    },
  },
}