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
    local weekdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
    return weekdays[today.wday]
end
local function get_hhmm()
    local today = os.date("*t")
    return string.format("%02d:%02d", today.hour, today.min)
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
    s(
        "details",
        fmt(
            [[
<!--
{}
-->
		  ]],
            { i(1) }
        )
    ),
    s(
        "details",
        fmt(
            [[
<details>
  <summary>{}</summary>

{}

</details>
      ]],
            { i(1), i(0) }
        )
    ),
}
