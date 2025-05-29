return {
  "olexsmir/gopher.nvim",
  ft = "go",
  -- branch = "develop"
  -- (optional) will update plugin's deps on every update
  build = function()
    vim.cmd.GoInstallDeps()
  end,
  ---@type gopher.Config

  config = function()
    require("gopher").setup({
      -- log level, you might consider using DEBUG or TRACE for debugging the plugin
      log_level = vim.log.levels.INFO,

      -- timeout for running internal commands
      timeout = 2000,
      installer_timeout = 2000,

      commands = {
        go = "go",
        gomodifytags = "gomodifytags",
        gotests = "gotests",
        impl = "impl",
        iferr = "iferr",
      },
      gotests = {
        -- gotests doesn't have template named "default" so this plugin uses "default" to set the default template
        template = "default",
        -- path to a directory containing custom test code templates
        template_dir = nil,
        -- switch table tests from using slice to map (with test name for the key)
        named = false,
      },
      gotag = {
        transform = "snakecase",
        -- default tags to add to struct fields
        default_tag = "json",
      },
      iferr = {
        -- choose a custom error message
        message = nil,
      },
    })
  end,
}
