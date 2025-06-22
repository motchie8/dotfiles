local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local function get_today_date()
	local today = os.date("*t")
	return string.format("%04d-%02d-%02d", today.year, today.month, today.day)
end
local function get_weekday()
	local today = os.date("*t")
	local weekdays = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" }
	return weekdays[today.wday]
end
return {
	s(
		"schedule",
		fmt(
			[[
# Diary for {date}({weekday})

## Current active tasks | status.not:Completed and +ACTIVE

## Events

## ad hoc tasks

## Today's tasks

## Schedule

| s | expected | actual | action | review |
|---|----------|--------|--------|--------|

## Memo
            ]],
			{ date = i(1, get_today_date()), weekday = i(2, get_weekday()) }
		)
	),
	s(
		"mtg",
		fmt(
			[[
                {}: {}-{}
            ]],
			{ i(1, "Meeting"), i(2, "09:00"), i(3, "10:00") }
		)
	),
	s(
		"task",
		fmt(
			[[
                [ ] {}: {}
            ]],
			{ i(1, "task"), i(2, "min") }
		)
	),
}
