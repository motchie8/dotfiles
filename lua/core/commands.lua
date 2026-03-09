local api = vim.api

-- Helper function to start AI tool based on environment variables
local function start_ai_tool()
    local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
    local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
    if use_claude_code == "1" then
        vim.fn.chansend(vim.b.terminal_job_id, "claude\n")
    elseif use_cursor_cli == "1" then
        vim.fn.chansend(vim.b.terminal_job_id, "cursor-agent\n")
    else
        print("Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them.")
    end
end

-- Vst: vertical split (right) + terminal, then return to original window
api.nvim_create_user_command("Vst", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow vs")
    vim.cmd("terminal")
    vim.fn.win_gotoid(original_win)
end, {})

-- Vsc: vertical split (right) + terminal + AI tool, then return to original window
api.nvim_create_user_command("Vsc", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow vs")
    vim.cmd("terminal")
    vim.schedule(function()
        start_ai_tool()
        vim.fn.win_gotoid(original_win)
    end)
end, {})

-- Hs: horizontal split (below)
api.nvim_create_user_command("Hs", function()
    vim.cmd("rightbelow split")
end, {})

-- Hst: horizontal split (below) + terminal, then return to original window
api.nvim_create_user_command("Hst", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow split")
    vim.cmd("terminal")
    vim.fn.win_gotoid(original_win)
end, {})

-- Hsc: horizontal split (below) + terminal + AI tool, then return to original window
api.nvim_create_user_command("Hsc", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow split")
    vim.cmd("terminal")
    vim.schedule(function()
        start_ai_tool()
        vim.fn.win_gotoid(original_win)
    end)
end, {})

-- Hse: horizontal split (above, 6 lines height) + open tmp.md, cursor moves to new window
api.nvim_create_user_command("Hse", function()
    vim.cmd("aboveleft 10split tmp.md")
end, {})

-- Command abbreviations for lowercase usage
vim.cmd("cnoreabbrev vst Vst")
vim.cmd("cnoreabbrev vsc Vsc")
vim.cmd("cnoreabbrev hs Hs")
vim.cmd("cnoreabbrev hst Hst")
vim.cmd("cnoreabbrev hsc Hsc")
vim.cmd("cnoreabbrev hse Hse")
