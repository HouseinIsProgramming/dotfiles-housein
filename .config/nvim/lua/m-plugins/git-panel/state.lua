---@class GitPanelState
---@field split table|nil NuiSplit instance
---@field bufnr number|nil Buffer number
---@field winnr number|nil Window number
---@field git_root string|nil Git repository root
---@field merge_base string|nil Merge base commit
---@field default_branch string|nil Default branch (main/master)
---@field working_files { staged: table[], unstaged: table[] }
---@field branch_files table[]
---@field loading { working: boolean, branch: boolean }
---@field error string|nil
---@field cursor_line number Current cursor line
---@field ns_id number Namespace for highlights
---@field on_change function|nil Callback for state changes

local M = {
	split = nil,
	bufnr = nil,
	winnr = nil,
	git_root = nil,
	merge_base = nil,
	default_branch = nil,
	working_files = { staged = {}, unstaged = {} },
	branch_files = {},
	loading = { working = true, branch = true },
	error = nil,
	cursor_line = 1,
	ns_id = nil,
	on_change = nil,
}

function M.reset()
	M.split = nil
	M.bufnr = nil
	M.winnr = nil
	M.git_root = nil
	M.merge_base = nil
	M.default_branch = nil
	M.working_files = { staged = {}, unstaged = {} }
	M.branch_files = {}
	M.loading = { working = true, branch = true }
	M.error = nil
	M.cursor_line = 1
end

---@param new_state table Partial state to merge
function M.set(new_state)
	for k, v in pairs(new_state) do
		M[k] = v
	end
	if M.on_change then
		M.on_change()
	end
end

function M.is_loading()
	return M.loading.working or M.loading.branch
end

function M.has_changes()
	return #M.working_files.staged > 0
		or #M.working_files.unstaged > 0
		or #M.branch_files > 0
end

return M
