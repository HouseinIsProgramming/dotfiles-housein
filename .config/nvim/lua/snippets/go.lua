local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("ifer", {
		t("if err != nil {"),
		t({ "", "\treturn err" }),
		t({ "", "}" }),
	}),
}