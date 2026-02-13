local state = require("m-plugins.git-panel.state")
local git = require("m-plugins.git-panel.git")
local ui = require("m-plugins.git-panel.ui")

local M = {}

local refresh_timer = nil
local DEBOUNCE_MS = 300

---Debounced refresh
local function debounced_refresh()
	if refresh_timer then
		vim.fn.timer_stop(refresh_timer)
	end
	refresh_timer = vim.fn.timer_start(DEBOUNCE_MS, function()
		refresh_timer = nil
		vim.schedule(function()
			M.refresh()
		end)
	end)
end

---Initialize git data for the panel
local function init_git_data()
	-- Check if we're in a git repo
	if not git.is_git_repo() then
		state.set({
			git_root = nil,
			loading = { working = false, branch = false },
		})
		return
	end

	-- Get git root
	git.get_git_root(function(err, root)
		if err or not root then
			state.set({
				error = err or "Failed to get git root",
				loading = { working = false, branch = false },
			})
			return
		end

		state.set({ git_root = root })

		-- Fetch working changes
		git.get_working_changes(root, function(work_err, working_files)
			if work_err then
				state.set({
					error = work_err,
					loading = { working = false, branch = state.loading.branch },
				})
			else
				state.set({
					working_files = working_files,
					loading = { working = false, branch = state.loading.branch },
				})
			end
		end)

		-- Detect default branch and get merge base
		git.detect_default_branch(root, function(branch_err, default_branch)
			if branch_err then
				state.set({
					default_branch = "main",
					loading = { working = state.loading.working, branch = false },
				})
				return
			end

			state.set({ default_branch = default_branch })

			-- Get merge base
			git.get_merge_base(root, default_branch, function(base_err, merge_base)
				if base_err then
					state.set({
						loading = { working = state.loading.working, branch = false },
					})
					return
				end

				state.set({ merge_base = merge_base })

				-- Get branch changes
				git.get_branch_changes(root, merge_base, function(changes_err, branch_files)
					if changes_err then
						state.set({
							loading = { working = state.loading.working, branch = false },
						})
					else
						state.set({
							branch_files = branch_files,
							loading = { working = state.loading.working, branch = false },
						})
					end
				end)
			end)
		end)
	end)
end

---Open file at cursor in the previous window
local function open_file_at_cursor()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor[1]

	-- Get file from line map (direct 1-indexed lookup)
	local file_entry = state.line_map and state.line_map[line_num]
	if not file_entry or not file_entry.path then
		return
	end

	local filepath = state.git_root and (state.git_root .. "/" .. file_entry.path) or file_entry.path

	-- Find the previous window (not the panel)
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local target_win = nil

	for _, win in ipairs(wins) do
		if win ~= state.winnr then
			local buf = vim.api.nvim_win_get_buf(win)
			local buftype = vim.bo[buf].buftype
			if buftype == "" or buftype == "acwrite" then
				target_win = win
				break
			end
		end
	end

	if target_win then
		vim.api.nvim_set_current_win(target_win)
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	else
		-- No suitable window, create a new one
		vim.cmd("wincmd l")
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
	end
end

---Open file in a split
local function open_file_in_split()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor[1]

	local file_entry = state.line_map and state.line_map[line_num]
	if not file_entry or not file_entry.path then
		return
	end

	local filepath = state.git_root and (state.git_root .. "/" .. file_entry.path) or file_entry.path

	vim.cmd("wincmd l")
	vim.cmd("vsplit " .. vim.fn.fnameescape(filepath))
end

---Open file in diffview (if installed)
local function open_in_diffview()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor[1]

	local file_entry = state.line_map and state.line_map[line_num]
	if not file_entry or not file_entry.path then
		return
	end

	local ok, _ = pcall(require, "diffview")
	if ok then
		vim.cmd("DiffviewOpen -- " .. vim.fn.fnameescape(file_entry.path))
	else
		vim.notify("Diffview not installed", vim.log.levels.WARN)
	end
end

---Setup keymaps for the panel buffer
local function setup_keymaps()
	local bufnr = state.bufnr
	if not bufnr then
		return
	end

	local opts = { buffer = bufnr, silent = true, nowait = true }

	-- Navigation: open file
	vim.keymap.set("n", "<CR>", open_file_at_cursor, vim.tbl_extend("force", opts, { desc = "Open file" }))
	vim.keymap.set("n", "s", open_file_in_split, vim.tbl_extend("force", opts, { desc = "Open in split" }))

	-- Refresh
	vim.keymap.set("n", "R", function()
		M.refresh()
	end, vim.tbl_extend("force", opts, { desc = "Refresh" }))

	-- Close
	vim.keymap.set("n", "q", function()
		M.close()
	end, vim.tbl_extend("force", opts, { desc = "Close panel" }))

	-- Diffview
	vim.keymap.set("n", "d", open_in_diffview, vim.tbl_extend("force", opts, { desc = "Open in diffview" }))
end

---Setup autocmds for auto-refresh
local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("GitPanel", { clear = true })

	-- Refresh on file save or read (skip if it's the panel buffer)
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
		group = group,
		callback = function(args)
			if args.buf == state.bufnr then
				return
			end
			debounced_refresh()
		end,
	})

	-- Refresh on focus gained
	vim.api.nvim_create_autocmd({ "FocusGained", "TermClose" }, {
		group = group,
		callback = debounced_refresh,
	})

	-- Full reinit on directory change
	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		callback = function()
			state.reset()
			state.loading = { working = true, branch = true }
			ui.render()
			init_git_data()
		end,
	})

	-- Re-render on window resize
	vim.api.nvim_create_autocmd("VimResized", {
		group = group,
		callback = function()
			ui.render()
		end,
	})

	-- Close vim if git-panel is the last window
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		callback = function()
			vim.schedule(function()
				local wins = vim.api.nvim_tabpage_list_wins(0)
				if #wins == 1 and wins[1] == state.winnr then
					vim.cmd("quit")
				end
			end)
		end,
	})
end

---Initialize and show the panel
local function init_panel()
	-- Setup highlights
	ui.setup_highlights()

	-- Set state change callback to re-render
	state.on_change = function()
		ui.render()
	end

	-- Create the split
	ui.create_split()

	-- Setup keymaps
	setup_keymaps()

	-- Render skeleton UI
	ui.render()

	-- Start async git data fetch
	init_git_data()

	-- Return focus to previous window
	vim.cmd("wincmd p")
end

---Setup the git panel (called on plugin load)
function M.setup()
	-- Setup autocmds for refresh behavior
	setup_autocmds()

	-- Setup toggle keymap (global)
	vim.keymap.set("n", "<leader>e", function()
		M.toggle_focus()
	end, { silent = true, desc = "Toggle git panel focus" })

	-- Open panel on first file read
	vim.api.nvim_create_autocmd("BufReadPost", {
		once = true,
		callback = function()
			vim.schedule(function()
				init_panel()
			end)
		end,
	})
end

---Refresh git data (silent - keeps existing data visible)
function M.refresh()
	if not state.git_root then
		init_git_data()
		return
	end

	-- Fetch working changes silently
	git.get_working_changes(state.git_root, function(err, working_files)
		if not err then
			state.set({ working_files = working_files })
		end
	end)

	-- Fetch branch changes silently
	if state.merge_base then
		git.get_branch_changes(state.git_root, state.merge_base, function(err, branch_files)
			if not err then
				state.set({ branch_files = branch_files })
			end
		end)
	end
end

---Toggle panel visibility
function M.toggle()
	ui.toggle()
	if ui.is_visible() then
		setup_keymaps()
	end
end

---Close the panel
function M.close()
	ui.hide()
end

---Show the panel
function M.show()
	ui.show()
	setup_keymaps()
end

---Focus the panel
function M.focus()
	if not ui.is_visible() then
		M.show()
	end
	ui.focus()
end

---Toggle focus between panel and editor
function M.toggle_focus()
	if ui.is_focused() then
		vim.cmd("wincmd p")
	else
		M.focus()
	end
end

return M
