// Zed settings
//
// For information on how to configure Zed, see the Zed
// documentation: https://zed.dev/docs/configuring-zed
//
// To see all of Zed's default settings without changing your
// custom settings, run `zed: open default settings` from the
// command palette
{
	"edit_predictions": {
		"disabled_globs": [
			"**/.git",
			"**/.svn",
			"**/.hg",
			"**/CVS",
			"**/.DS_Store",
			"**/Thumbs.db",
			"**/.classpath",
			"**/.settings",
			"**/.vscode",
			"**/.idea",
			"**/node_modules",
			"**/.serverless",
			"**/build",
			"**/dist",
			"**/coverage",
			"**/.venv",
			"**/__pycache__",
			"**/.ropeproject",
			"**/.pytest_cache",
			"**/.ruff_cache"
		],
		"mode": "eager",
		"copilot": {
			"proxy": null,
			"proxy_no_verify": null
		},
		"enabled_in_assistant": false
	},
	"icon_theme": "Catppuccin Mocha",
	"notification_panel": {
		"enabled": false,
		"button": false
	},

	"assistant": {
		"default_profile": "ask",
		"default_model": {
			"provider": "zed.dev",
			"model": "claude-3-7-sonnet-latest"
		},
		"version": "2"
	},
	"show_edit_predictions": true,
	"languages": {
		"Python": {
			"language_servers": ["ruff", "basedpyright", "!pyright"],
			"formatter": [
				{
					"code_actions": {
						"source.organizeImports.ruff": true,
						"source.fixAll.ruff": true
					}
				},
				{
					"language_server": {
						"name": "ruff"
					}
				}
			]
		}
	},
	"lsp": {
		"basedpyright": {
			"settings": {
				"python": {
					"pythonPath": "./.venv/bin/python"
				},
				"basedpyright.analysis": {
					"diagnosticMode": "workspace",
					"inlayHints": {
						"callArgumentNames": false
					}
				}
			}
		},
		"gopls": {
			"gofumpt": true,
			"initialization_options": {
				"gofumpt": true
			}
		},
		"yaml-language-server": {
			"settings": {
				"yaml": {
					"validate": false,
					"customTags": [
						"!And scalar",
						"!And mapping",
						"!And sequence",
						"!If scalar",
						"!If mapping",
						"!If sequence",
						"!Not scalar",
						"!Not mapping",
						"!Not sequence",
						"!Equals scalar",
						"!Equals mapping",
						"!Equals sequence",
						"!Or scalar",
						"!Or mapping",
						"!Or sequence",
						"!FindInMap scalar",
						"!FindInMap mapping",
						"!FindInMap sequence",
						"!Base64 scalar",
						"!Base64 mapping",
						"!Base64 sequence",
						"!Cidr scalar",
						"!Cidr mapping",
						"!Cidr sequence",
						"!Ref scalar",
						"!Ref mapping",
						"!Ref sequence",
						"!Sub scalar",
						"!Sub mapping",
						"!Sub sequence",
						"!GetAtt scalar",
						"!GetAtt mapping",
						"!GetAtt sequence",
						"!GetAZs scalar",
						"!GetAZs mapping",
						"!GetAZs sequence",
						"!ImportValue scalar",
						"!ImportValue mapping",
						"!ImportValue sequence",
						"!Select scalar",
						"!Select mapping",
						"!Select sequence",
						"!Split scalar",
						"!Split mapping",
						"!Split sequence",
						"!Join scalar",
						"!Join mapping",
						"!Join sequence",
						"!Condition scalar",
						"!Condition mapping",
						"!Condition sequence"
					],
					"format": {
						"enable": true,
						"singleQuote": true
					},
					"editor": {
						"tabSize": 4
					},
					"schemas": {
						"https://raw.githubusercontent.com/lalcebo/json-schema/master/serverless/reference.json": [
							"/*"
						]
					}
				}
			}
		}
	},
	"tab_size": 4,
	"telemetry": {
		"diagnostics": false,
		"metrics": false
	},
	"vim_mode": true,
	"relative_line_numbers": true,
	"scrollbar": {
		"show": "never"
	},
	"tab_bar": {
		"show": true,
		"show_nav_history_buttons": false
	},
	"tabs": {
		"file_icons": true,
		"git_status": true
	},
	// Indentation, rainbow indentation
	"indent_guides": {
		"enabled": true,
		"coloring": "indent_aware"
	},
	// Use zed commit editor
	"terminal": {
		"env": {
			"EDITOR": "zed --wait"
		},
		"font_size": 16,
		"font_family": "BlexMono Nerd Font Mono",
		"detect_venv": {
			"on": {
				// Default directories to search for virtual environments, relative
				// to the current working directory. We recommend overriding this
				// in your project's settings, rather than globally.
				"directories": [".venv", "venv"],
				// Can also be `csh`, `fish`, and `nushell`
				"activate_script": "default"
			}
		},
		"button": false
	},
	"toolbar": {
		"title": false,
		"quick_actions": false
	},
	// NOTE: Zen mode, refer https://github.com/zed-industries/zed/issues/4382 when it's resolved
	"centered_layout": {
		"left_padding": 0.15,
		"right_padding": 0.15
	},
	// File syntax highlighting
	"file_types": {
		"Dockerfile": ["Dockerfile", "Dockerfile.*"],
		"JSON": ["json", "jsonc", "*.code-snippets"]
	},
	"file_scan_exclusions": [
		"**/.git",
		"**/.svn",
		"**/.hg",
		"**/CVS",
		"**/.DS_Store",
		"**/Thumbs.db",
		"**/.classpath",
		"**/.settings",
		"**/.vscode",
		"**/.idea",
		"**/node_modules",
		"**/.serverless",
		"**/build",
		"**/dist",
		"**/coverage",
		"**/.venv",
		"**/__pycache__",
		"**/.ropeproject",
		"**/.pytest_cache",
		"**/.ruff_cache"
	],
	"file_scan_inclusions": [".env"],
	// Move all panel to the right
	"project_panel": {
		"button": false,
		"default_width": 300,
		"dock": "left",
		"file_icons": true,
		"folder_icons": true,
		"git_status": true,
		"scrollbar": {
			"show": "never"
		}
	},
	"outline_panel": {
		"dock": "right",
		"button": false
	},
	"collaboration_panel": {
		"dock": "left",
		"button": false
	},
	"chat_panel": {
		"dock": "right"
	},
	"ui_font_size": 16,
	"buffer_font_size": 16,
	"buffer_font_family": "BlexMono Nerd Font Mono",
	"ui_font_family": "BlexMono Nerd Font Mono",
	"autosave": "on_focus_change",
	"theme": {
		"mode": "dark",
		"light": "One Light",
		"dark": "Catppuccin Mocha"
	},
	"search": {
		"whole_word": false,
		"case_sensitive": true,
		"include_ignored": false,
		"regex": false
	},
	"projects_online_by_default": false,
	"preferred_line_length": 120,
	"features": {
		"edit_prediction_provider": "zed"
	},
	"formatter": {
		"language_server": {
			"name": "biome"
		}
	},
	"code_actions_on_format": {
		"source.fixAll.biome": true,
		"source.organizeImports.biome": true
	}
}

