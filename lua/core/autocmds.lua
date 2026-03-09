-- Keymap for help file
vim.api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        -- Jump to tag
        vim.keymap.set("n", "<Leader>jt", "<C-]>", opts)
        -- Jump back
        vim.keymap.set("n", "<Leader>jb", "<C-T>", opts)
    end,
})

-- # file watch # --
local file_watch_group = vim.api.nvim_create_augroup("FileWatch", { clear = true })

-- checktime を定期的に呼び出し、外部変更を検知する
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = file_watch_group,
    pattern = "*",
    callback = function()
        if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
        end
    end,
})

-- 未保存変更ありの場合: snacks.nvim で通知
vim.api.nvim_create_autocmd("FileChangedShell", {
    group = file_watch_group,
    pattern = "*",
    callback = function()
        local filepath = vim.fn.expand("<afile>")
        Snacks.notify.warn(
            string.format(
                "ファイルが外部で変更されました: %s\n未保存の変更があるためリロードしませんでした。",
                filepath
            ),
            { title = "ファイル変更検知" }
        )
        vim.v.fcs_choice = "ignore"
    end,
})

-- 未保存変更なしの場合: 自動リロード後に通知
vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = file_watch_group,
    pattern = "*",
    callback = function()
        local filepath = vim.fn.expand("<afile>")
        Snacks.notify.info(
            string.format("ファイルをリロードしました: %s", filepath),
            { title = "ファイル変更検知" }
        )
    end,
})
