-- Macro to convert PR number to GitHub link
-- Usage: position cursor on PR number, press @l
-- Converts "123" to "#[123](https://github.com/feddersen-group/feddersen-monorepo/pull/123)"
vim.fn.setreg("l", '_w"ayiWciW#[a](https://github.com/feddersen-group/feddersen-monorepo/pull/a)\x1b')
