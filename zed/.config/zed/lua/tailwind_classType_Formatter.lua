#!/usr/bin/env lua

-- Function to format Tailwind class names
local function format_tailwind_classes(class_str)
	local groups = {
		base = {},
		before = {},
		after = {},
		sm = {},
		md = {},
		lg = {},
		xl = {},
		other = {},
	}

	-- Split classes by space
	for class in class_str:gmatch("%S+") do
		if class:match("^before:") then
			table.insert(groups.before, class)
		elseif class:match("^after:") then
			table.insert(groups.after, class)
		elseif class:match("^sm:") then
			table.insert(groups.sm, class)
		elseif class:match("^md:") then
			table.insert(groups.md, class)
		elseif class:match("^lg:") then
			table.insert(groups.lg, class)
		elseif class:match("^xl:") then
			table.insert(groups.xl, class)
		else
			table.insert(groups.base, class)
		end
	end

	-- Reassemble formatted class string
	local formatted = {}
	if #groups.base > 0 then
		table.insert(formatted, table.concat(groups.base, " "))
	end
	if #groups.before > 0 then
		table.insert(formatted, table.concat(groups.before, " "))
	end
	if #groups.after > 0 then
		table.insert(formatted, table.concat(groups.after, " "))
	end
	if #groups.sm > 0 then
		table.insert(formatted, table.concat(groups.sm, " "))
	end
	if #groups.md > 0 then
		table.insert(formatted, table.concat(groups.md, " "))
	end
	if #groups.lg > 0 then
		table.insert(formatted, table.concat(groups.lg, " "))
	end
	if #groups.xl > 0 then
		table.insert(formatted, table.concat(groups.xl, " "))
	end

	return table.concat(formatted, "\n")
end

-- Read the entire input from stdin
local input = io.read("*all")

-- Process `className="..."` attributes
local output = input:gsub('className%s*=%s*"([^"]+)"', function(class_str)
	return 'className="' .. format_tailwind_classes(class_str) .. '"'
end)

-- Output the modified content to stdout
io.write(output)
