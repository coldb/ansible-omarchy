-- Assign applications to their preferred workspaces.
o.window("Cursor", { workspace = "1 silent" })
o.window("com\\.t3tools\\.T3Code", { workspace = "1 silent" })
o.window("com.mitchellh.ghostty", { workspace = "2" })
o.window("chromium", { workspace = "3 silent" })
o.window("md\\.obsidian\\.Obsidian", { workspace = "5 silent" })
o.window("brave-browser", { workspace = "8 silent" })
o.window("org.mozilla.Thunderbird", { workspace = "9 silent" })

-- Prevent applications from stealing focus after launch.
o.window("md\\.obsidian\\.Obsidian", { focus_on_activate = false })
o.window("chromium", { focus_on_activate = false })
o.window("brave-browser", { focus_on_activate = false })
o.window("Cursor", { focus_on_activate = false })
o.window("com\\.t3tools\\.T3Code", { focus_on_activate = false })

-- Ensure workspace 2 stays focused after startup applications launch.
o.exec_on_start("sleep 3 && hyprctl dispatch workspace 2")
