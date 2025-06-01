---@diagnostic disable: undefined-global

-- instant movement for built-in window management
hs.window.animationDuration = 0

hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
    "home.toml",
    "work.toml",
    "Spoons/Hammerflow.spoon/sample.toml",
    "Spoons/Hammerflow.spoon/home.toml",
    "Spoons/Hammerflow.spoon/work.toml",
})
if spoon.Hammerflow.auto_reload then
    hs.loadSpoon("ReloadConfiguration")
    spoon.ReloadConfiguration:start()
end
