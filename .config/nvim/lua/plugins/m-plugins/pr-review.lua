return {
	name = "pr-review",
	cond = not vim.g.is_vscode,
	dir = vim.fn.stdpath("config") .. "/lua/plugins/m-plugins/pr-review",
	virtual = true,
	cmd = "PRReview",
	config = function()
		-- ══════════════════════════════════════════════════════════════════════
		-- GitHub API Layer
		-- ══════════════════════════════════════════════════════════════════════

		local function get_current_repo()
			local handle = io.popen("git remote get-url origin 2>/dev/null")
			if not handle then
				return nil
			end
			local remote = handle:read("*a")
			handle:close()
			if not remote or remote == "" then
				return nil
			end
			remote = remote:gsub("%s+$", "")
			local owner, repo = remote:match("github%.com[:/]([^/]+)/([^/%.]+)")
			if owner and repo then
				return { owner = owner, repo = repo }
			end
			return nil
		end

		local function parse_pr_input(input)
			local pr_num = input:match("^(%d+)$")
			if pr_num then
				local repo_info = get_current_repo()
				if repo_info then
					return { owner = repo_info.owner, repo = repo_info.repo, number = tonumber(pr_num) }
				end
				return nil
			end
			local owner, repo, number = input:match("github%.com/([^/]+)/([^/]+)/pull/(%d+)")
			if owner and repo and number then
				return { owner = owner, repo = repo, number = tonumber(number) }
			end
			return nil
		end

		local function gh_async(cmd, callback)
			local stdout_data = {}
			local stderr_data = {}
			vim.fn.jobstart(cmd, {
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
							local output = table.concat(stdout_data, "\n")
							if output == "" then
								callback(nil, nil)
							else
								local ok, json = pcall(vim.fn.json_decode, output)
								if ok then
									callback(nil, json)
								else
									callback(nil, output)
								end
							end
						else
							callback(table.concat(stderr_data, "\n"), nil)
						end
					end)
				end,
			})
		end

		local function fetch_pr_info(pr_ref, callback)
			local cmd = string.format(
				"gh pr view %d -R %s/%s --json title,body,state,headRefOid,baseRefOid,baseRefName,headRefName,author,additions,deletions,changedFiles",
				pr_ref.number,
				pr_ref.owner,
				pr_ref.repo
			)
			gh_async(cmd, function(err, data)
				if err then
					callback(err, nil)
				else
					if data then
						data.owner = pr_ref.owner
						data.repo = pr_ref.repo
						data.number = pr_ref.number
					end
					callback(nil, data)
				end
			end)
		end

		local function fetch_pr_files(pr_ref, callback)
			local cmd = string.format(
				"gh api repos/%s/%s/pulls/%d/files --paginate",
				pr_ref.owner,
				pr_ref.repo,
				pr_ref.number
			)
			gh_async(cmd, callback)
		end

		local function submit_review_api(pr, event, body, comments, callback)
			local comments_json = vim.fn.json_encode(comments)
			local cmd = string.format(
				[[gh api -X POST repos/%s/%s/pulls/%d/reviews -f event=%s -f body=%s -f comments=%s]],
				pr.owner,
				pr.repo,
				pr.number,
				event,
				vim.fn.shellescape(body),
				vim.fn.shellescape(comments_json)
			)
			gh_async(cmd, callback)
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- Diff Parser
		-- ══════════════════════════════════════════════════════════════════════

		local function parse_patch(patch)
			if not patch then
				return {}
			end
			local hunks = {}
			local current_hunk = nil
			local position = 0
			local old_line = 0
			local new_line = 0

			for line in (patch .. "\n"):gmatch("([^\n]*)\n") do
				if line:match("^@@") then
					if current_hunk then
						table.insert(hunks, current_hunk)
					end
					local old_start, new_start = line:match("^@@ %-(%d+).-+(%d+)")
					old_line = tonumber(old_start) - 1
					new_line = tonumber(new_start) - 1
					current_hunk = { header = line, lines = {} }
					position = position + 1
				elseif current_hunk then
					position = position + 1
					local prefix = line:sub(1, 1)
					local content = line:sub(2)

					if prefix == "-" then
						old_line = old_line + 1
						table.insert(current_hunk.lines, {
							type = "-",
							text = content,
							old_num = old_line,
							new_num = nil,
							position = position,
							side = "LEFT",
						})
					elseif prefix == "+" then
						new_line = new_line + 1
						table.insert(current_hunk.lines, {
							type = "+",
							text = content,
							old_num = nil,
							new_num = new_line,
							position = position,
							side = "RIGHT",
						})
					else
						old_line = old_line + 1
						new_line = new_line + 1
						table.insert(current_hunk.lines, {
							type = " ",
							text = content,
							old_num = old_line,
							new_num = new_line,
							position = position,
							side = "RIGHT",
						})
					end
				end
			end
			if current_hunk then
				table.insert(hunks, current_hunk)
			end
			return hunks
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- Syntax Highlighting (regex-based for reliability)
		-- ══════════════════════════════════════════════════════════════════════

		local function setup_syntax_highlights()
			-- Create highlight groups that combine syntax colors with diff backgrounds
			local diff_add_bg = vim.api.nvim_get_hl(0, { name = "DiffAdd", link = false }).bg
			local diff_del_bg = vim.api.nvim_get_hl(0, { name = "DiffDelete", link = false }).bg
			local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg

			local syntax_colors = {
				Keyword = vim.api.nvim_get_hl(0, { name = "Keyword", link = false }),
				String = vim.api.nvim_get_hl(0, { name = "String", link = false }),
				Comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false }),
				Type = vim.api.nvim_get_hl(0, { name = "Type", link = false }),
				Function = vim.api.nvim_get_hl(0, { name = "Function", link = false }),
				Number = vim.api.nvim_get_hl(0, { name = "Number", link = false }),
				Constant = vim.api.nvim_get_hl(0, { name = "Constant", link = false }),
			}

			for name, def in pairs(syntax_colors) do
				if def.fg then
					vim.api.nvim_set_hl(0, "PRDiffAdd" .. name, { fg = def.fg, bg = diff_add_bg, bold = def.bold, italic = def.italic })
					vim.api.nvim_set_hl(0, "PRDiffDel" .. name, { fg = def.fg, bg = diff_del_bg, bold = def.bold, italic = def.italic })
					vim.api.nvim_set_hl(0, "PRDiffCtx" .. name, { fg = def.fg, bg = normal_bg, bold = def.bold, italic = def.italic })
				end
			end
		end

		-- Patterns for syntax highlighting (applied via matchadd)
		local syntax_patterns = {
			{ pattern = [[\<\(import\|export\|from\|const\|let\|var\|function\|return\|if\|else\|for\|while\|class\|interface\|type\|enum\|async\|await\|try\|catch\|throw\|new\|this\|extends\|implements\)\>]], group = "Keyword" },
			{ pattern = [["[^"]*"\|'[^']*'\|`[^`]*`]], group = "String" },
			{ pattern = [[//.*$\|/\*.\{-}\*/]], group = "Comment" },
			{ pattern = [[\<\d\+\>]], group = "Number" },
			{ pattern = [[\<\(true\|false\|null\|undefined\|nil\)\>]], group = "Constant" },
		}

		local function apply_syntax_matches(bufnr)
			-- Clear old matches and apply new ones
			vim.api.nvim_buf_call(bufnr, function()
				pcall(vim.fn.clearmatches)
				for _, pat in ipairs(syntax_patterns) do
					pcall(vim.fn.matchadd, pat.group, pat.pattern)
				end
			end)
		end

		local function get_git_root_sync()
			local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
			if not handle then return nil end
			local root = handle:read("*a")
			handle:close()
			return root and root:gsub("%s+$", "") or nil
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- State
		-- ══════════════════════════════════════════════════════════════════════

		local state = {
			pr = nil,
			files = {},
			current_file_idx = 1,
			comments = {},
			review_body = "",
			loading = true,
			error = nil,
			confirm_dialog = nil,
			bufnr = nil,
			winnr = nil,
			comment_section_lines = {},  -- {buffer_line -> comment_idx}
			ns_id = nil,
			line_map = {},  -- {buffer_line -> {file_idx, old_line, new_line, filename}}
		}

		-- ══════════════════════════════════════════════════════════════════════
		-- Rendering
		-- ══════════════════════════════════════════════════════════════════════

		local function render()
			if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
				return
			end

			local lines = {}
			local highlights = {}

			local function add(text, hl)
				local line_idx = #lines
				if hl then
					table.insert(highlights, { line_idx, 0, #text, hl })
				end
				table.insert(lines, text)
			end

			local function add_hl(line_idx, col_start, col_end, hl)
				table.insert(highlights, { line_idx, col_start, col_end, hl })
			end

			if state.loading then
				add("Loading PR data...", "Comment")
				vim.bo[state.bufnr].modifiable = true
				vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
				vim.bo[state.bufnr].modifiable = false
				return
			end

			if state.error then
				add("Error: " .. state.error, "ErrorMsg")
				vim.bo[state.bufnr].modifiable = true
				vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
				vim.bo[state.bufnr].modifiable = false
				return
			end

			local pr = state.pr
			if pr then
				add(string.format("PR #%d: %s", pr.number, pr.title or ""), "Title")
				add(string.format("  %s -> %s  +%d -%d  (%d files)",
					pr.headRefName or "", pr.baseRefName or "",
					pr.additions or 0, pr.deletions or 0, pr.changedFiles or 0), "Comment")
				add("")
			end

			-- File list
			add("Files:", "Title")
			state.file_list_start = #lines + 1  -- 1-indexed line number where files start
			for i, f in ipairs(state.files) do
				local status_icon = ({ added = "+", modified = "~", removed = "-", renamed = "R" })[f.status] or "?"
				local is_current = i == state.current_file_idx
				local prefix = is_current and "> " or "  "
				local line_text = prefix .. status_icon .. " " .. (f.filename or "unknown")
				add(line_text, is_current and "CursorLine" or nil)
			end
			state.file_list_end = #lines  -- 1-indexed line number where files end
			add("")

			-- Diff views for ALL files
			local width = state.winnr and vim.api.nvim_win_is_valid(state.winnr) and vim.api.nvim_win_get_width(state.winnr) or 120
			local half = math.floor((width - 3) / 2)

			local function pad(str, len)
				str = str or ""
				local display_width = vim.fn.strdisplaywidth(str)
				if display_width > len then
					local result = ""
					local current_width = 0
					for char in vim.gsplit(str, "") do
						local char_width = vim.fn.strdisplaywidth(char)
						if current_width + char_width >= len then
							break
						end
						result = result .. char
						current_width = current_width + char_width
					end
					return result .. string.rep(" ", len - vim.fn.strdisplaywidth(result))
				end
				return str .. string.rep(" ", len - display_width)
			end

			state.file_diff_lines = {}  -- Track line number where each file's diff starts
			state.line_map = {}  -- Clear line map

			-- Build comment lookup: {filename -> {line_num -> comment}}
			local comment_lookup = {}
			for _, comment in ipairs(state.comments) do
				if not comment_lookup[comment.path] then
					comment_lookup[comment.path] = {}
				end
				for ln = comment.start_line or comment.line, comment.end_line or comment.line do
					comment_lookup[comment.path][ln] = comment
				end
			end

			for file_idx, file in ipairs(state.files) do
				state.file_diff_lines[file_idx] = #lines + 1  -- 1-indexed line where this file starts

				add(string.rep("═", width), "NonText")
				local is_current = file_idx == state.current_file_idx
				local marker = is_current and ">> " or "   "
				add(marker .. string.format("File %d/%d: %s  +%d -%d", file_idx, #state.files, file.filename, file.additions or 0, file.deletions or 0), is_current and "CursorLine" or "Title")
				add(string.rep("─", width), "NonText")
				add(pad("OLD", half) .. " | " .. pad("NEW", half), "Comment")

				local hunks = parse_patch(file.patch)
				for _, hunk in ipairs(hunks) do
					-- Extract just the line numbers from hunk header (remove trailing context)
					local hunk_info = hunk.header:match("^(@@ %-%d+,%d+ %+%d+,%d+ @@)") or hunk.header:match("^(@@ %-%d+ %+%d+,%d+ @@)") or hunk.header:match("^(@@ %-%d+,%d+ %+%d+ @@)") or hunk.header
					add(string.rep("·", 10) .. " " .. hunk_info .. " " .. string.rep("·", 10), "Comment")

					local old_lines_arr = {}
					local new_lines_arr = {}

					for _, line in ipairs(hunk.lines) do
						if line.type == "-" then
							table.insert(old_lines_arr, { text = line.text, hl = "DiffDelete", meta = line })
						elseif line.type == "+" then
							table.insert(new_lines_arr, { text = line.text, hl = "DiffAdd", meta = line })
						else
							while #old_lines_arr < #new_lines_arr do
								table.insert(old_lines_arr, { text = "", hl = "Normal", meta = nil })
							end
							while #new_lines_arr < #old_lines_arr do
								table.insert(new_lines_arr, { text = "", hl = "Normal", meta = nil })
							end
							table.insert(old_lines_arr, { text = line.text, hl = "Normal", meta = line })
							table.insert(new_lines_arr, { text = line.text, hl = "Normal", meta = line })
						end
					end

					while #old_lines_arr < #new_lines_arr do
						table.insert(old_lines_arr, { text = "", hl = "Normal", meta = nil })
					end
					while #new_lines_arr < #old_lines_arr do
						table.insert(new_lines_arr, { text = "", hl = "Normal", meta = nil })
					end

					for i = 1, #old_lines_arr do
						local old = old_lines_arr[i]
						local new = new_lines_arr[i]
						local new_line_num = new.meta and new.meta.new_num

						-- Check if this line has a comment
						local has_comment = new_line_num and comment_lookup[file.filename] and comment_lookup[file.filename][new_line_num]
						local comment_marker = has_comment and "*" or " "

						local old_num = old.meta and old.meta.old_num and string.format("%4d", old.meta.old_num) or "    "
						local new_num = new_line_num and string.format("%3d%s", new_line_num, comment_marker) or "    "

						local left_text = old_num .. " " .. pad(old.text, half - 5)
						local right_text = new_num .. " " .. pad(new.text, half - 5)
						local full_line = left_text .. " | " .. right_text

						local line_idx = #lines
						table.insert(lines, full_line)

						-- Store line mapping for gd navigation
						state.line_map[line_idx + 1] = {
							file_idx = file_idx,
							filename = file.filename,
							old_line = old.meta and old.meta.old_num,
							new_line = new_line_num,
						}

						-- Apply diff background highlights
						local left_bytes = #left_text
						add_hl(line_idx, 0, left_bytes, old.hl)
						add_hl(line_idx, left_bytes, left_bytes + 3, "NonText")
						add_hl(line_idx, left_bytes + 3, #full_line, new.hl)

						-- Highlight comment marker
						if has_comment then
							local marker_pos = left_bytes + 3 + 3  -- after " | " and "123"
							add_hl(line_idx, marker_pos, marker_pos + 1, "WarningMsg")
						end
					end
				end
				add("")
			end

			add("")
			add(string.rep("─", width), "NonText")
			add("<leader>ra=Approve | <leader>rr=Request Changes | <leader>rc=Submit as comment", "Comment")
			add("<CR>=Select file | ]f/[f=Nav | <leader>c=Comment | r=Edit | x=Remove | gf=Open | gd=Def | q=Close", "Comment")
			add("")

			-- Show pending comments with their line content
			state.comment_section_lines = {}  -- Clear and rebuild

			if #state.comments > 0 then
				add(string.format("PENDING COMMENTS (%d)", #state.comments), "WarningMsg")
				add(string.rep("─", 40), "NonText")

				for idx, comment in ipairs(state.comments) do
					local line_range = comment.start_line == comment.end_line
						and string.format("L%d", comment.start_line)
						or string.format("L%d-%d", comment.start_line, comment.end_line)

					-- Get all line contents from the file's patch for this range
					local line_contents = {}
					for _, file in ipairs(state.files) do
						if file.filename == comment.path then
							local hunks = parse_patch(file.patch)
							for _, hunk in ipairs(hunks) do
								for _, line in ipairs(hunk.lines) do
									if line.new_num and line.new_num >= comment.start_line and line.new_num <= comment.end_line then
										line_contents[line.new_num] = line.text or ""
									end
								end
							end
							break
						end
					end

					-- Comment header - track this line
					local header = string.format("[%d] %s:%s", idx, comment.path:match("[^/]+$") or comment.path, line_range)
					state.comment_section_lines[#lines + 1] = idx
					add(header, "Title")

					-- Show all lines in the range - track these lines
					for ln = comment.start_line, comment.end_line do
						local content = line_contents[ln]
						if content then
							local line_prefix = string.format("  %4d ", ln)
							local preview = content:sub(1, 70)
							if #content > 70 then preview = preview .. "..." end
							local content_line_idx = #lines
							state.comment_section_lines[#lines + 1] = idx
							add(line_prefix .. preview, "Normal")
							-- Highlight line number
							table.insert(highlights, { content_line_idx, 0, #line_prefix, "LineNr" })
						end
					end

					-- Comment body - track this line
					state.comment_section_lines[#lines + 1] = idx
					add("       > " .. comment.body, "String")
					add("")
				end
			else
				add("No pending comments", "Comment")
			end

			if state.confirm_dialog and state.confirm_dialog.visible then
				add("")
				add(string.rep("═", 50), "WarningMsg")
				local action_labels = {
					APPROVE = "APPROVE this PR",
					REQUEST_CHANGES = "REQUEST CHANGES on this PR",
					COMMENT = "Submit as COMMENT",
				}
				add("CONFIRM: " .. (action_labels[state.confirm_dialog.action] or ""), "WarningMsg")
				add(string.format("Comments to submit: %d", #state.comments), "Number")
				add("Press 'y' to confirm, 'n' or <Esc> to cancel", "Question")
				add(string.rep("═", 50), "WarningMsg")
			end

			vim.bo[state.bufnr].modifiable = true
			vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
			vim.bo[state.bufnr].modifiable = false

			vim.api.nvim_buf_clear_namespace(state.bufnr, state.ns_id, 0, -1)
			for _, hl in ipairs(highlights) do
				local line_idx, col_start, col_end, hl_group = hl[1], hl[2], hl[3], hl[4]
				if line_idx < #lines then
					pcall(vim.api.nvim_buf_add_highlight, state.bufnr, state.ns_id, hl_group, line_idx, col_start, col_end)
				end
			end

			-- Apply regex-based syntax highlighting
			apply_syntax_matches(state.bufnr)
		end

		local function set_state(new_state)
			for k, v in pairs(new_state) do
				state[k] = v
			end
			render()
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- Actions
		-- ══════════════════════════════════════════════════════════════════════

		local function scroll_to_file(file_idx)
			if state.file_diff_lines and state.file_diff_lines[file_idx] then
				local target_line = state.file_diff_lines[file_idx]
				vim.api.nvim_win_set_cursor(0, { target_line, 0 })
				vim.cmd("normal! zt")  -- Scroll to top of window
				state.current_file_idx = file_idx
				render()  -- Re-render to update highlights
			end
		end

		local function next_file()
			local new_idx = math.min(state.current_file_idx + 1, #state.files)
			scroll_to_file(new_idx)
		end

		local function prev_file()
			local new_idx = math.max(state.current_file_idx - 1, 1)
			scroll_to_file(new_idx)
		end

		local function select_file_at_cursor()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1]  -- 1-indexed
			if state.file_list_start and state.file_list_end then
				if cursor_line >= state.file_list_start and cursor_line <= state.file_list_end then
					local file_idx = cursor_line - state.file_list_start + 1
					if file_idx >= 1 and file_idx <= #state.files then
						scroll_to_file(file_idx)
					end
				end
			end
		end

		local function go_to_definition()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
			local line_info = state.line_map[cursor_line]

			if not line_info then
				vim.notify("No source line at cursor", vim.log.levels.WARN)
				return
			end

			local target_line = line_info.new_line or line_info.old_line
			if not target_line then
				vim.notify("No line number available", vim.log.levels.WARN)
				return
			end

			local git_root = get_git_root_sync()
			local filepath = git_root and (git_root .. "/" .. line_info.filename) or line_info.filename

			if vim.fn.filereadable(filepath) ~= 1 then
				vim.notify("File not found: " .. line_info.filename, vim.log.levels.ERROR)
				return
			end

			-- Open file in new tab
			vim.cmd.tabedit(vim.fn.fnameescape(filepath))

			-- Go to the line
			vim.api.nvim_win_set_cursor(0, { target_line, 0 })

			-- Wait for LSP to attach, then trigger go to definition
			vim.defer_fn(function()
				vim.lsp.buf.definition()
			end, 100)
		end

		local function add_comment(start_line, end_line)
			-- Get line info from cursor or visual selection
			start_line = start_line or vim.api.nvim_win_get_cursor(0)[1]
			end_line = end_line or start_line

			local line_info = state.line_map[start_line]
			if not line_info then
				vim.notify("Cursor not on a diff line", vim.log.levels.WARN)
				return
			end

			local file = state.files[line_info.file_idx]
			if not file then
				vim.notify("No file found", vim.log.levels.WARN)
				return
			end

			-- Collect all line numbers in the range
			local start_new_line = line_info.new_line
			local end_new_line = start_new_line

			if end_line > start_line then
				local end_info = state.line_map[end_line]
				if end_info and end_info.new_line then
					end_new_line = end_info.new_line
				end
			end

			-- Find position in diff
			local hunks = parse_patch(file.patch)
			local position = nil
			for _, hunk in ipairs(hunks) do
				for _, line in ipairs(hunk.lines) do
					if line.new_num == start_new_line then
						position = line.position
						break
					end
				end
				if position then break end
			end

			if not position then
				vim.notify("Line not in diff (only context lines can be commented)", vim.log.levels.WARN)
				return
			end

			local line_desc = start_new_line == end_new_line
				and string.format("Line %d", start_new_line)
				or string.format("Lines %d-%d", start_new_line, end_new_line)

			vim.ui.input({ prompt = string.format("Comment on %s: ", line_desc) }, function(comment_body)
				if not comment_body or comment_body == "" then
					return
				end

				local comments = vim.deepcopy(state.comments)
				table.insert(comments, {
					path = file.filename,
					line = start_new_line,
					start_line = start_new_line,
					end_line = end_new_line,
					position = position,
					body = comment_body,
					side = "RIGHT",
				})
				set_state({ comments = comments })
				vim.notify(string.format("Comment added to %s:%s", file.filename, line_desc))
			end)
		end

		local function find_comment_at_cursor()
			local cursor_line = vim.api.nvim_win_get_cursor(0)[1]

			-- First check if cursor is in the pending comments section
			local comment_idx = state.comment_section_lines[cursor_line]
			if comment_idx and state.comments[comment_idx] then
				return comment_idx, state.comments[comment_idx]
			end

			-- Then check if cursor is on a diff line with a comment
			local line_info = state.line_map[cursor_line]
			if line_info and line_info.new_line then
				for idx, comment in ipairs(state.comments) do
					if comment.path == line_info.filename then
						local start_ln = comment.start_line or comment.line
						local end_ln = comment.end_line or comment.line
						if line_info.new_line >= start_ln and line_info.new_line <= end_ln then
							return idx, comment
						end
					end
				end
			end
			return nil, nil
		end

		local function edit_comment()
			local idx, comment = find_comment_at_cursor()
			if not comment then
				vim.notify("No comment at cursor", vim.log.levels.WARN)
				return
			end

			vim.ui.input({
				prompt = "Edit comment: ",
				default = comment.body,
			}, function(new_body)
				if not new_body or new_body == "" then
					return
				end
				local comments = vim.deepcopy(state.comments)
				comments[idx].body = new_body
				set_state({ comments = comments })
				vim.notify("Comment updated")
			end)
		end

		local function remove_comment()
			local idx, comment = find_comment_at_cursor()
			if not comment then
				vim.notify("No comment at cursor", vim.log.levels.WARN)
				return
			end

			local line_range = (comment.start_line or comment.line) == (comment.end_line or comment.line)
				and string.format("L%d", comment.start_line or comment.line)
				or string.format("L%d-%d", comment.start_line or comment.line, comment.end_line or comment.line)

			vim.ui.select({ "Yes", "No" }, {
				prompt = string.format("Remove comment on %s:%s?", comment.path:match("[^/]+$"), line_range),
			}, function(choice)
				if choice == "Yes" then
					local comments = vim.deepcopy(state.comments)
					table.remove(comments, idx)
					set_state({ comments = comments })
					vim.notify("Comment removed")
				end
			end)
		end

		local function get_git_root()
			local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
			if not handle then
				return nil
			end
			local root = handle:read("*a")
			handle:close()
			if root and root ~= "" then
				return root:gsub("%s+$", "")
			end
			return nil
		end

		local function open_full_file()
			local file = state.files[state.current_file_idx]
			if not file then
				vim.notify("No file selected", vim.log.levels.WARN)
				return
			end

			local git_root = get_git_root()
			local filepath = git_root and (git_root .. "/" .. file.filename) or file.filename

			if vim.fn.filereadable(filepath) == 1 then
				vim.cmd.tabedit(vim.fn.fnameescape(filepath))
			else
				vim.notify("File not found locally: " .. file.filename, vim.log.levels.WARN)
			end
		end

		local function do_close_review()
			if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
				vim.api.nvim_buf_delete(state.bufnr, { force = true })
			end
			state.pr = nil
			state.files = {}
			state.current_file_idx = 1
			state.comments = {}
			state.bufnr = nil
			state.winnr = nil
		end

		local function close_review()
			if #state.comments > 0 then
				vim.ui.select({ "Yes, discard comments", "No, keep reviewing" }, {
					prompt = string.format("You have %d pending comment(s). Close anyway?", #state.comments),
				}, function(choice)
					if choice == "Yes, discard comments" then
						do_close_review()
					end
				end)
			else
				do_close_review()
			end
		end

		local function show_confirm(action)
			set_state({ confirm_dialog = { action = action, visible = true } })
		end

		local function cancel_confirm()
			set_state({ confirm_dialog = nil })
		end

		local function submit_review()
			local dialog = state.confirm_dialog
			if not dialog then
				return
			end

			local pr = state.pr
			local api_comments = {}
			for _, c in ipairs(state.comments) do
				table.insert(api_comments, {
					path = c.path,
					position = c.position,
					body = c.body,
				})
			end

			set_state({ confirm_dialog = nil, loading = true })

			submit_review_api(pr, dialog.action, state.review_body or "", api_comments, function(err, _)
				if err then
					set_state({ loading = false, error = err })
					vim.notify("Review submission failed: " .. err, vim.log.levels.ERROR)
				else
					vim.notify("Review submitted successfully!", vim.log.levels.INFO)
					close_review()
				end
			end)
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- Keymaps
		-- ══════════════════════════════════════════════════════════════════════

		local function setup_keymaps(bufnr)
			local opts = { buffer = bufnr, silent = true }

			vim.keymap.set("n", "]f", next_file, vim.tbl_extend("force", opts, { desc = "PR: Next file" }))
			vim.keymap.set("n", "[f", prev_file, vim.tbl_extend("force", opts, { desc = "PR: Prev file" }))
			vim.keymap.set("n", "<CR>", select_file_at_cursor, vim.tbl_extend("force", opts, { desc = "PR: Select file" }))
			vim.keymap.set("n", "<leader>c", function() add_comment() end, vim.tbl_extend("force", opts, { desc = "PR: Add comment" }))
			vim.keymap.set("x", "<leader>c", function()
				local start_line = vim.fn.line("'<")
				local end_line = vim.fn.line("'>")
				add_comment(start_line, end_line)
			end, vim.tbl_extend("force", opts, { desc = "PR: Add comment on selection" }))
			vim.keymap.set("n", "r", edit_comment, vim.tbl_extend("force", opts, { desc = "PR: Edit comment" }))
			vim.keymap.set("n", "x", remove_comment, vim.tbl_extend("force", opts, { desc = "PR: Remove comment" }))
			vim.keymap.set("n", "gf", open_full_file, vim.tbl_extend("force", opts, { desc = "PR: Open full file" }))
			vim.keymap.set("n", "gd", go_to_definition, vim.tbl_extend("force", opts, { desc = "PR: Go to definition" }))
			vim.keymap.set("n", "<leader>ra", function()
				show_confirm("APPROVE")
			end, vim.tbl_extend("force", opts, { desc = "PR: Approve" }))
			vim.keymap.set("n", "<leader>rr", function()
				show_confirm("REQUEST_CHANGES")
			end, vim.tbl_extend("force", opts, { desc = "PR: Request changes" }))
			vim.keymap.set("n", "<leader>rc", function()
				show_confirm("COMMENT")
			end, vim.tbl_extend("force", opts, { desc = "PR: Comment" }))
			vim.keymap.set("n", "q", close_review, vim.tbl_extend("force", opts, { desc = "PR: Close" }))

			vim.keymap.set("n", "y", function()
				if state.confirm_dialog and state.confirm_dialog.visible then
					submit_review()
				end
			end, vim.tbl_extend("force", opts, { desc = "PR: Confirm yes" }))

			vim.keymap.set("n", "n", function()
				if state.confirm_dialog and state.confirm_dialog.visible then
					cancel_confirm()
				end
			end, vim.tbl_extend("force", opts, { desc = "PR: Confirm no" }))

			vim.keymap.set("n", "<Esc>", function()
				if state.confirm_dialog and state.confirm_dialog.visible then
					cancel_confirm()
				end
			end, vim.tbl_extend("force", opts, { desc = "PR: Cancel confirm" }))
		end

		-- ══════════════════════════════════════════════════════════════════════
		-- Main Entry
		-- ══════════════════════════════════════════════════════════════════════

		local function open_pr_review(input)
			local pr_ref = parse_pr_input(input)
			if not pr_ref then
				vim.notify("Invalid PR input. Use PR number or full GitHub URL", vim.log.levels.ERROR)
				return
			end

			local bufnr = vim.api.nvim_create_buf(false, true)
			vim.bo[bufnr].buftype = "nofile"
			vim.bo[bufnr].bufhidden = "wipe"
			vim.bo[bufnr].swapfile = false
			vim.api.nvim_buf_set_name(bufnr, string.format("PR Review: %s/%s#%d", pr_ref.owner, pr_ref.repo, pr_ref.number))

			vim.cmd("tabnew")
			vim.api.nvim_win_set_buf(0, bufnr)
			local winnr = vim.api.nvim_get_current_win()

			vim.wo[winnr].wrap = false
			vim.wo[winnr].number = false
			vim.wo[winnr].relativenumber = false
			vim.wo[winnr].signcolumn = "no"

			state.bufnr = bufnr
			state.winnr = winnr
			state.ns_id = vim.api.nvim_create_namespace("pr_review")
			state.pr = nil
			state.files = {}
			state.current_file_idx = 1
			state.comments = {}
			state.review_body = ""
			state.loading = true
			state.error = nil
			state.confirm_dialog = nil

			render()
			setup_keymaps(bufnr)

			fetch_pr_info(pr_ref, function(err, pr_data)
				if err then
					set_state({ loading = false, error = err })
					return
				end

				fetch_pr_files(pr_ref, function(files_err, files_data)
					if files_err then
						set_state({ loading = false, error = files_err, pr = pr_data })
						return
					end

					set_state({
						loading = false,
						pr = pr_data,
						files = files_data or {},
					})
				end)
			end)
		end

		vim.api.nvim_create_user_command("PRReview", function(opts)
			setup_syntax_highlights()  -- Setup combined highlight groups
			local input = opts.args
			if input == "" then
				vim.ui.input({ prompt = "PR # or URL: " }, function(user_input)
					if user_input and user_input ~= "" then
						open_pr_review(user_input)
					end
				end)
			else
				open_pr_review(input)
			end
		end, {
			nargs = "?",
			desc = "Open GitHub PR review interface",
		})
	end,
}
