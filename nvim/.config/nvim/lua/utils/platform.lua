-- utils/platform.lua
-- 플랫폼 감지 유틸리티

local M = {}

M.is_mac = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_mac
M.is_wsl = vim.fn.has("wsl") == 1

---@return "macos"|"linux"|"wsl"
function M.os_name()
    if M.is_wsl then return "wsl" end
    if M.is_mac then return "macos" end
    return "linux"
end

---@param cmd string
---@return boolean
function M.has_cmd(cmd)
    return vim.fn.executable(cmd) == 1
end

return M
