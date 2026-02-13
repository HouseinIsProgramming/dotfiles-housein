local M = {}

---Run a git command asynchronously
---@param cmd string|string[] Command to run
---@param cwd string|nil Working directory
---@param callback fun(err: string|nil, data: string|nil)
local function git_async(cmd, cwd, callback)
	local stdout_data = {}
	local stderr_data = {}

	local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or cmd

	vim.fn.jobstart(cmd_str, {
		cwd = cwd,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout_data, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr_data, data)
			end
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if code == 0 then
					local output = table.concat(stdout_data, "\n"):gsub("%s+$", "")
					callback(nil, output)
				else
					local err = table.concat(stderr_data, "\n"):gsub("%s+$", "")
					callback(err ~= "" and err or "Command failed", nil)
				end
			end)
		end,
	})
end

---Get git repository root
---@param callback fun(err: string|nil, root: string|nil)
function M.get_git_root(callback)
	git_async("git rev-parse --show-toplevel", nil, callback)
end

---Check if we're in a git repository (sync for quick check)
---@return boolean
function M.is_git_repo()
	local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
	if not handle then
		return false
	end
	local result = handle:read("*a")
	handle:close()
	return result:match("true") ~= nil
end

---Detect the default branch (main vs master)
---@param git_root string
---@param callback fun(err: string|nil, branch: string|nil)
function M.detect_default_branch(git_root, callback)
	-- First try to get the default branch from remote
	git_async("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null", git_root, function(err, data)
		if not err and data and data ~= "" then
			local branch = data:match("refs/remotes/origin/(.+)")
			if branch then
				callback(nil, branch)
				return
			end
		end

		-- Fallback: check if main or master exists
		git_async("git rev-parse --verify main 2>/dev/null", git_root, function(main_err)
			if not main_err then
				callback(nil, "main")
				return
			end

			git_async("git rev-parse --verify master 2>/dev/null", git_root, function(master_err)
				if not master_err then
					callback(nil, "master")
					return
				end

				-- Default to main if neither exists
				callback(nil, "main")
			end)
		end)
	end)
end

---Get merge base between HEAD and default branch
---@param git_root string
---@param branch string
---@param callback fun(err: string|nil, merge_base: string|nil)
function M.get_merge_base(git_root, branch, callback)
	local cmd = string.format("git merge-base HEAD %s 2>/dev/null", branch)
	git_async(cmd, git_root, function(err, data)
		if err or not data or data == "" then
			-- Fallback: use branch directly if merge-base fails
			git_async("git rev-parse " .. branch .. " 2>/dev/null", git_root, function(rev_err, rev_data)
				if rev_err then
					callback(rev_err, nil)
				else
					callback(nil, rev_data)
				end
			end)
		else
			callback(nil, data)
		end
	end)
end

---Parse git status --porcelain output
---@param output string
---@return { staged: table[], unstaged: table[] }
local function parse_status(output)
	local result = { staged = {}, unstaged = {} }

	if not output or output == "" then
		return result
	end

	for line in output:gmatch("[^\r\n]+") do
		if #line >= 3 then
			local index_status = line:sub(1, 1)
			local worktree_status = line:sub(2, 2)
			local filepath = line:sub(4)

			-- Handle renamed files: "R  old -> new"
			local display_path = filepath
			if filepath:match(" %-> ") then
				local old, new = filepath:match("(.+) %-> (.+)")
				display_path = new or filepath
			end

			-- Staged changes (index status)
			if index_status ~= " " and index_status ~= "?" then
				table.insert(result.staged, {
					status = index_status,
					path = display_path,
					raw = filepath,
				})
			end

			-- Unstaged changes (worktree status)
			if worktree_status ~= " " then
				table.insert(result.unstaged, {
					status = worktree_status == "?" and "?" or worktree_status,
					path = display_path,
					raw = filepath,
				})
			end
		end
	end

	return result
end

---Get working directory changes
---@param git_root string
---@param callback fun(err: string|nil, files: { staged: table[], unstaged: table[] }|nil)
function M.get_working_changes(git_root, callback)
	git_async("git status --porcelain", git_root, function(err, data)
		if err then
			callback(err, nil)
			return
		end
		callback(nil, parse_status(data or ""))
	end)
end

---Parse git diff --name-status output
---@param output string
---@return table[]
local function parse_diff_name_status(output)
	local result = {}

	if not output or output == "" then
		return result
	end

	for line in output:gmatch("[^\r\n]+") do
		local status, filepath = line:match("^(%w)%s+(.+)$")
		if status and filepath then
			-- Handle renamed files
			local display_path = filepath
			if filepath:match("\t") then
				local parts = vim.split(filepath, "\t")
				display_path = parts[2] or filepath
			end

			table.insert(result, {
				status = status,
				path = display_path,
				raw = filepath,
			})
		end
	end

	return result
end

---Get branch changes (diff against merge base)
---@param git_root string
---@param merge_base string
---@param callback fun(err: string|nil, files: table[]|nil)
function M.get_branch_changes(git_root, merge_base, callback)
	local cmd = string.format("git diff --name-status %s..HEAD", merge_base)
	git_async(cmd, git_root, function(err, data)
		if err then
			callback(err, nil)
			return
		end
		callback(nil, parse_diff_name_status(data or ""))
	end)
end

---Get current branch name
---@param git_root string
---@param callback fun(err: string|nil, branch: string|nil)
function M.get_current_branch(git_root, callback)
	git_async("git rev-parse --abbrev-ref HEAD", git_root, callback)
end

return M
