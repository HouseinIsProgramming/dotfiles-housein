---@diagnostic disable: undefined-field, need-check-nil
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
	opts = {
		current_line_blame_opts = {
			delay = 200,
			virtual_text = true,
		},
		current_line_blame = false,
		auto_attach = true,
		numhl = true,
		attach_to_untracked = false,

		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local conf = require("telescope.config").values
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Gitsigns Telescope picker
			local function gitsigns_picker()
				local git_actions = {
					{
						name = "Stage Hunk",
						action = function()
							gs.stage_hunk()
						end,
					},
					{
						name = "Reset Hunk",
						action = function()
							gs.reset_hunk()
						end,
					},
					{
						name = "Stage Buffer",
						action = function()
							gs.stage_buffer()
						end,
					},
					{
						name = "Reset Buffer",
						action = function()
							gs.reset_buffer()
						end,
					},
					{
						name = "Undo Stage Hunk",
						action = function()
							gs.undo_stage_hunk()
						end,
					},
					{
						name = "Preview Hunk",
						action = function()
							gs.preview_hunk()
						end,
					},
					{
						name = "Blame Line",
						action = function()
							gs.blame_line({ full = true })
						end,
					},
					{
						name = "Diff This",
						action = function()
							gs.diffthis()
						end,
					},
					{
						name = "Diff This ~",
						action = function()
							gs.diffthis("~")
						end,
					},
					{
						name = "Next Hunk",
						action = function()
							gs.next_hunk()
						end,
					},
					{
						name = "Previous Hunk",
						action = function()
							gs.prev_hunk()
						end,
					},
					{
						name = "Toggle Line Blame",
						action = function()
							gs.toggle_current_line_blame()
						end,
					},
					{
						name = "Toggle Deleted",
						action = function()
							gs.toggle_deleted()
						end,
					},
					{
						name = "Toggle Signs",
						action = function()
							gs.toggle_signs()
						end,
					},
					{
						name = "Toggle Word Diff",
						action = function()
							gs.toggle_word_diff()
						end,
					},
					{
						name = "Toggle Line Highlight",
						action = function()
							gs.toggle_linehl()
						end,
					},
					{
						name = "Toggle Number Highlight",
						action = function()
							gs.toggle_numhl()
						end,
					},
				}

				local entries = {}
				for _, item in ipairs(git_actions) do
					table.insert(entries, {
						value = item,
						display = item.name,
						ordinal = item.name,
					})
				end

				pickers
					.new({}, {
						prompt_title = "Gitsigns",
						finder = finders.new_table({
							results = entries,
							entry_maker = function(entry)
								return {
									value = entry.value,
									display = entry.display,
									ordinal = entry.ordinal,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(prompt_bufnr, map)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if selection and selection.value and selection.value.action then
									selection.value.action()
								end
							end)
							return true
						end,
					})
					:find()
			end

			-- Navigation
			map("n", "]h", function()
				if vim.wo.diff then
					return "]h"
				end
				vim.schedule(function()
					gs.next_hunk()
				end)
				return "<Ignore>"
			end, { expr = true })

			map("n", "[h", function()
				if vim.wo.diff then
					return "[h"
				end
				vim.schedule(function()
					gs.prev_hunk()
				end)
				return "<Ignore>"
			end, { expr = true })

			-- Actions
			map("n", "du", gs.stage_hunk, { desc = "Stage hunk" })
			map("n", "dU", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
			map("n", "do", gs.preview_hunk, { desc = "Preview hunk" })
			map("n", "dp", gs.reset_hunk, { desc = "Reset hunk" })
			map("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, { desc = "Blame line" })
			map("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
			map("n", "<leader>gD", function()
				gs.diffthis("~")
			end, { desc = "Diff this ~" })

			-- Gitsigns picker
			map("n", "<leader>gh", gitsigns_picker, { desc = "Gitsigns picker" })

			-- Text object
			map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
		end,
	},
}
