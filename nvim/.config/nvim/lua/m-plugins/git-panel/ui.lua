local state = require("m-plugins.git-panel.state")
local Split = require("nui.split")

local M = {}

local WIDTH = 35
local MAX_PATH_LEN = 28

---Status icon mapping
local STATUS_ICONS = {
	M = "~",
	A = "+",
	D = "-",
	R = "R",
	C = "C",
	U = "U",
	["?"] = "?",
	["!"] = "!",
}

---Get file icon using nvim-web-devicons
---@param filename string
---@return string icon, string|nil highlight
local function get_file_icon(filename)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return "", nil
	end
	local ext = filename:match("%.([^%.]+)$")
	local icon, hl = devicons.get_icon(filename, ext, { default = true })
	return icon or "", hl
end

---Truncate path with leading ellipsis
---@param path string
---@param max_len number
---@return string
local function truncate_path(path, max_len)
	if #path <= max_len then
		return path
	end
	return "..." .. path:sub(-(max_len - 3))
end

---Create the NuiSplit panel
---@return table split
function M.create_split()
	local split = Split({
		relative = "editor",
		position = "left",
		size = WIDTH,
		win_options = {
			winfixwidth = true,
			number = false,
			relativenumber = false,
			signcolumn = "no",
			foldcolumn = "0",
			wrap = false,
			cursorline = true,
			winhighlight = "Normal:Normal,CursorLine:Visual",
		},
		buf_options = {
			buftype = "nofile",
			bufhidden = "hide",
			swapfile = false,
			modifiable = false,
			filetype = "git-panel",
		},
	})

	split:mount()

	state.split = split
	state.bufnr = split.bufnr
	state.winnr = split.winid
	state.ns_id = vim.api.nvim_create_namespace("git_panel")

	return split
end

---Setup highlight groups
function M.setup_highlights()
	vim.api.nvim_set_hl(0, "GitPanelHeader", { bold = true, link = "Title" })
	vim.api.nvim_set_hl(0, "GitPanelSeparator", { link = "NonText" })
	vim.api.nvim_set_hl(0, "GitPanelStaged", { fg = "#a6e3a1", bold = true })
	vim.api.nvim_set_hl(0, "GitPanelUnstaged", { fg = "#f9e2af" })
	vim.api.nvim_set_hl(0, "GitPanelAdded", { fg = "#a6e3a1" })
	vim.api.nvim_set_hl(0, "GitPanelModified", { fg = "#89b4fa" })
	vim.api.nvim_set_hl(0, "GitPanelDeleted", { fg = "#f38ba8" })
	vim.api.nvim_set_hl(0, "GitPanelUntracked", { fg = "#cdd6f4" })
	vim.api.nvim_set_hl(0, "GitPanelLoading", { fg = "#6c7086", italic = true })
	vim.api.nvim_set_hl(0, "GitPanelError", { fg = "#f38ba8", bold = true })
	vim.api.nvim_set_hl(0, "GitPanelBranch", { fg = "#cba6f7", italic = true })
end

---Get highlight for status
---@param status string
---@return string
local function get_status_highlight(status)
	local map = {
		A = "GitPanelAdded",
		M = "GitPanelModified",
		D = "GitPanelDeleted",
		R = "GitPanelModified",
		C = "GitPanelAdded",
		["?"] = "GitPanelUntracked",
		["!"] = "GitPanelUntracked",
	}
	return map[status] or "Normal"
end

---Render the panel content
function M.render()
	local bufnr = state.bufnr
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local lines = {}
	local highlights = {}

	-- Line map: 1-indexed line number -> file entry
	state.line_map = {}

	local function add_line(text, hl_group)
		local line_idx = #lines
		table.insert(lines, text)
		if hl_group then
			table.insert(highlights, { line_idx, 0, #text, hl_group })
		end
		return line_idx + 1 -- Return 1-indexed line number
	end

	local function add_highlight(line_idx, col_start, col_end, hl_group)
		table.insert(highlights, { line_idx, col_start, col_end, hl_group })
	end

	-- Handle error state
	if state.error then
		add_line("  ERROR", "GitPanelError")
		add_line("", nil)
		for err_line in state.error:gmatch("[^\n]+") do
			add_line("  " .. err_line:sub(1, WIDTH - 4), "GitPanelError")
		end
	elseif not state.git_root then
		-- Handle non-git directory
		add_line("", nil)
		add_line("  Not a git repository", "GitPanelLoading")
	else
		-- Section: WORKING CHANGES
		add_line(" WORKING CHANGES", "GitPanelHeader")
		add_line(" " .. string.rep("─", WIDTH - 2), "GitPanelSeparator")

		if state.loading.working then
			add_line("  Loading...", "GitPanelLoading")
		else
			-- Staged files
			if #state.working_files.staged > 0 then
				add_line(" Staged:", "GitPanelStaged")
				for _, file in ipairs(state.working_files.staged) do
					local icon, icon_hl = get_file_icon(file.path)
					local status_icon = STATUS_ICONS[file.status] or "?"
					local display_path = truncate_path(file.path, MAX_PATH_LEN - 5)
					local file_line = string.format("   %s %s %s", status_icon, icon, display_path)
					local line_idx = #lines

					table.insert(lines, file_line)

					-- Store in line_map with 1-indexed line number
					state.line_map[line_idx + 1] = {
						type = "staged",
						path = file.path,
						status = file.status,
					}

					-- Status icon highlight
					add_highlight(line_idx, 3, 4, get_status_highlight(file.status))
					-- File icon highlight
					if icon_hl then
						add_highlight(line_idx, 5, 5 + #icon, icon_hl)
					end
				end
			end

			-- Unstaged files
			if #state.working_files.unstaged > 0 then
				add_line(" Unstaged:", "GitPanelUnstaged")
				for _, file in ipairs(state.working_files.unstaged) do
					local icon, icon_hl = get_file_icon(file.path)
					local status_icon = STATUS_ICONS[file.status] or "?"
					local display_path = truncate_path(file.path, MAX_PATH_LEN - 5)
					local file_line = string.format("   %s %s %s", status_icon, icon, display_path)
					local line_idx = #lines

					table.insert(lines, file_line)

					-- Store in line_map with 1-indexed line number
					state.line_map[line_idx + 1] = {
						type = "unstaged",
						path = file.path,
						status = file.status,
					}

					add_highlight(line_idx, 3, 4, get_status_highlight(file.status))
					if icon_hl then
						add_highlight(line_idx, 5, 5 + #icon, icon_hl)
					end
				end
			end

			if #state.working_files.staged == 0 and #state.working_files.unstaged == 0 then
				add_line("  No changes", "GitPanelLoading")
			end
		end

		add_line("", nil)

		-- Section: BRANCH CHANGES
		local branch_header = " BRANCH CHANGES"
		if state.default_branch then
			branch_header = branch_header .. " (vs " .. state.default_branch .. ")"
		end
		add_line(branch_header, "GitPanelHeader")
		add_line(" " .. string.rep("─", WIDTH - 2), "GitPanelSeparator")

		if state.loading.branch then
			add_line("  Loading...", "GitPanelLoading")
		else
			if #state.branch_files > 0 then
				for _, file in ipairs(state.branch_files) do
					local icon, icon_hl = get_file_icon(file.path)
					local status_icon = STATUS_ICONS[file.status] or "?"
					local display_path = truncate_path(file.path, MAX_PATH_LEN - 5)
					local file_line = string.format("   %s %s %s", status_icon, icon, display_path)
					local line_idx = #lines

					table.insert(lines, file_line)

					-- Store in line_map with 1-indexed line number
					state.line_map[line_idx + 1] = {
						type = "branch",
						path = file.path,
						status = file.status,
					}

					add_highlight(line_idx, 3, 4, get_status_highlight(file.status))
					if icon_hl then
						add_highlight(line_idx, 5, 5 + #icon, icon_hl)
					end
				end
			else
				add_line("  No changes from " .. (state.default_branch or "base"), "GitPanelLoading")
			end
		end
	end

	-- Apply to buffer
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].modifiable = false

	-- Apply highlights
	vim.api.nvim_buf_clear_namespace(bufnr, state.ns_id, 0, -1)
	for _, hl in ipairs(highlights) do
		local line_idx, col_start, col_end, hl_group = hl[1], hl[2], hl[3], hl[4]
		if line_idx < #lines then
			pcall(vim.api.nvim_buf_add_highlight, bufnr, state.ns_id, hl_group, line_idx, col_start, col_end)
		end
	end
end

---Show panel
function M.show()
	if state.split and state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		return
	end
	M.create_split()
	M.render()
end

---Hide panel
function M.hide()
	if state.split then
		state.split:unmount()
		state.split = nil
		state.bufnr = nil
		state.winnr = nil
	end
end

---Toggle panel visibility
function M.toggle()
	if state.split and state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		M.hide()
	else
		M.show()
	end
end

---Check if panel is visible
---@return boolean
function M.is_visible()
	return state.split ~= nil and state.winnr ~= nil and vim.api.nvim_win_is_valid(state.winnr)
end

---Focus the panel window
function M.focus()
	if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		vim.api.nvim_set_current_win(state.winnr)
	end
end

---Check if panel is focused
---@return boolean
function M.is_focused()
	return state.winnr ~= nil and vim.api.nvim_get_current_win() == state.winnr
end

return M
