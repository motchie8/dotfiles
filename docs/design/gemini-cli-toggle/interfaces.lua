-- Gemini CLI Toggle Lua インターフェース定義
-- 🟢 要件定義書に基づくLua型定義（TypeScript風のコメント記法を使用）

--[[
このファイルはLuaの型定義として機能し、実装時の参考として使用する。
Luaは動的型付け言語のため、実際の型チェックは実行時に行われる。
--]]

-- ターミナル状態を表現する構造体
-- @class GeminiTerminalState 🟢
-- @field terminal_id number|nil toggleterm.nvimが管理するターミナルID
-- @field buffer_id number|nil Neovimバッファの識別子
-- @field window_id number|nil Neovimウィンドウの識別子
-- @field is_visible boolean ターミナルがウィンドウに表示されているか
-- @field process_id number|nil Gemini CLIプロセスのPID
-- @field status string ターミナルの状態 ("not_exists" | "visible" | "hidden" | "error")

---@class GeminiTerminalState
local GeminiTerminalState = {
    terminal_id = nil,    -- toggleterm.nvim terminal ID
    buffer_id = nil,      -- Neovim buffer ID
    window_id = nil,      -- Neovim window ID  
    is_visible = false,   -- terminal visibility status
    process_id = nil,     -- Gemini CLI process ID
    status = "not_exists" -- "not_exists" | "visible" | "hidden" | "error"
}

-- ターミナル設定を表現する構造体 🟢
-- @class GeminiTerminalConfig
-- @field direction string ターミナルの表示方向 ("vertical" | "horizontal" | "float" | "tab")
-- @field size number|nil ターミナルのサイズ（ピクセルまたは割合）
-- @field cmd string 実行するコマンド ("gemini")
-- @field display_name string ターミナルの表示名
-- @field auto_scroll boolean 自動スクロールの有効化

---@class GeminiTerminalConfig
local GeminiTerminalConfig = {
    direction = "vertical", -- terminal display direction
    size = 70,             -- terminal size
    cmd = "gemini",        -- command to execute
    display_name = "Gemini CLI", -- terminal display name
    auto_scroll = true     -- enable auto scroll
}

-- エラー情報を表現する構造体 🟡
-- @class GeminiError
-- @field code string エラーコード
-- @field message string エラーメッセージ
-- @field details string|nil 詳細情報
-- @field suggestions table|nil 解決策の配列

---@class GeminiError
local GeminiError = {
    code = "",            -- error code ("GEMINI_NOT_FOUND" | "TERMINAL_CREATE_FAILED" | etc.)
    message = "",         -- human readable error message
    details = nil,        -- optional detailed information
    suggestions = nil     -- optional array of solution suggestions
}

-- コマンド実行結果を表現する構造体 🟡
-- @class CommandResult
-- @field success boolean コマンドが成功したか
-- @field data any|nil 成功時のデータ
-- @field error GeminiError|nil エラー情報

---@class CommandResult
local CommandResult = {
    success = false,      -- command execution success
    data = nil,          -- result data on success
    error = nil          -- error information on failure
}

-- toggleterm.nvim API のラッパーインターフェース 🟡
-- @class ToggletermAPI
-- @field get_terminal function(id: number) -> table|nil
-- @field create_terminal function(config: table) -> table
-- @field toggle_terminal function(id: number) -> nil
-- @field send_cmd function(id: number, cmd: string) -> nil

---@class ToggletermAPI
local ToggletermAPI = {
    -- 指定IDのターミナルを取得
    get_terminal = function(id)
        -- toggleterm API call implementation
        return nil
    end,
    
    -- 新しいターミナルを作成
    create_terminal = function(config)
        -- toggleterm API call implementation
        return {}
    end,
    
    -- ターミナルの表示をトグル
    toggle_terminal = function(id)
        -- toggleterm API call implementation
    end,
    
    -- ターミナルにコマンドを送信
    send_cmd = function(id, cmd)
        -- toggleterm API call implementation
    end
}

-- Neovim API のラッパーインターフェース 🟢
-- @class NeovimAPI
-- @field create_user_command function(name: string, command: function|string, opts: table) -> nil
-- @field set_keymap function(mode: string, lhs: string, rhs: string, opts: table) -> nil
-- @field get_current_buf function() -> number
-- @field list_wins function() -> table
-- @field buf_is_valid function(buf: number) -> boolean
-- @field win_is_valid function(win: number) -> boolean

---@class NeovimAPI
local NeovimAPI = {
    -- ユーザーコマンドを作成
    create_user_command = function(name, command, opts)
        vim.api.nvim_create_user_command(name, command, opts or {})
    end,
    
    -- キーマッピングを設定
    set_keymap = function(mode, lhs, rhs, opts)
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts or {})
    end,
    
    -- 現在のバッファIDを取得
    get_current_buf = function()
        return vim.api.nvim_get_current_buf()
    end,
    
    -- 全ウィンドウのリストを取得
    list_wins = function()
        return vim.api.nvim_list_wins()
    end,
    
    -- バッファが有効かチェック
    buf_is_valid = function(buf)
        return vim.api.nvim_buf_is_valid(buf)
    end,
    
    -- ウィンドウが有効かチェック
    win_is_valid = function(win)
        return vim.api.nvim_win_is_valid(win)
    end
}

-- メインのGemini CLI Toggle クラス 🟢
-- @class GeminiCLIToggle
-- @field state GeminiTerminalState 現在のターミナル状態
-- @field config GeminiTerminalConfig ターミナル設定
-- @field detect_state function() -> GeminiTerminalState
-- @field create_terminal function() -> CommandResult
-- @field show_terminal function() -> CommandResult
-- @field hide_terminal function() -> CommandResult
-- @field toggle function() -> CommandResult

---@class GeminiCLIToggle
local GeminiCLIToggle = {
    state = GeminiTerminalState,
    config = GeminiTerminalConfig,
    
    -- 現在のターミナル状態を検出
    detect_state = function(self)
        -- Implementation: ターミナル状態の検出ロジック
        -- @return GeminiTerminalState
        return self.state
    end,
    
    -- 新しいGemini CLIターミナルを作成
    create_terminal = function(self)
        -- Implementation: 新規ターミナル作成ロジック
        -- @return CommandResult
        return CommandResult
    end,
    
    -- 既存のターミナルを表示
    show_terminal = function(self)
        -- Implementation: ターミナル表示ロジック
        -- @return CommandResult
        return CommandResult
    end,
    
    -- ターミナルを非表示にする
    hide_terminal = function(self)
        -- Implementation: ターミナル非表示ロジック
        -- @return CommandResult
        return CommandResult
    end,
    
    -- メインのトグル機能
    toggle = function(self)
        -- Implementation: 状態に応じたトグル処理
        -- @return CommandResult
        return CommandResult
    end
}

-- システムユーティリティ関数 🟡
-- @class SystemUtils
-- @field check_command_exists function(cmd: string) -> boolean
-- @field get_working_directory function() -> string
-- @field format_error_message function(error: GeminiError) -> string

---@class SystemUtils
local SystemUtils = {
    -- コマンドの存在確認
    check_command_exists = function(cmd)
        -- Implementation: which/where コマンドによる存在確認
        -- @param cmd string コマンド名
        -- @return boolean 存在するかどうか
        return false
    end,
    
    -- 現在の作業ディレクトリを取得
    get_working_directory = function()
        -- Implementation: pwd コマンドまたはLua io.popen
        -- @return string 作業ディレクトリパス
        return ""
    end,
    
    -- エラーメッセージのフォーマット
    format_error_message = function(error)
        -- Implementation: ユーザーフレンドリーなエラーメッセージ生成
        -- @param error GeminiError エラー情報
        -- @return string フォーマット済みメッセージ
        return ""
    end
}

-- 設定の検証とデフォルト値の適用 🟡
-- @class ConfigValidator
-- @field validate_config function(config: GeminiTerminalConfig) -> boolean
-- @field merge_with_defaults function(config: table) -> GeminiTerminalConfig
-- @field get_default_config function() -> GeminiTerminalConfig

---@class ConfigValidator
local ConfigValidator = {
    -- 設定の妥当性を検証
    validate_config = function(config)
        -- Implementation: 設定値の妥当性チェック
        -- @param config GeminiTerminalConfig 検証する設定
        -- @return boolean 設定が妥当かどうか
        return true
    end,
    
    -- デフォルト設定とマージ
    merge_with_defaults = function(config)
        -- Implementation: ユーザー設定とデフォルト設定のマージ
        -- @param config table ユーザー設定
        -- @return GeminiTerminalConfig マージ済み設定
        return GeminiTerminalConfig
    end,
    
    -- デフォルト設定を取得
    get_default_config = function()
        -- Implementation: デフォルト設定の返却
        -- @return GeminiTerminalConfig デフォルト設定
        return GeminiTerminalConfig
    end
}

-- エクスポート用のテーブル 🟢
-- 実際の実装ではこれらの定義を使用してモジュールを構築する
local M = {
    GeminiTerminalState = GeminiTerminalState,
    GeminiTerminalConfig = GeminiTerminalConfig,
    GeminiError = GeminiError,
    CommandResult = CommandResult,
    ToggletermAPI = ToggletermAPI,
    NeovimAPI = NeovimAPI,
    GeminiCLIToggle = GeminiCLIToggle,
    SystemUtils = SystemUtils,
    ConfigValidator = ConfigValidator
}

return M