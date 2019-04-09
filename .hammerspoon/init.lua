-- [Getting Started](http:--www.hammerspoon.org/go/)
-- [API Docs](https:--www.hammerspoon.org/docs/)
local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };

--[[--  快捷键：窗口缩放
--]]
--[[window resize begin]]
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "0", function()
    hs.alert.show("全屏");
    local win = hs.window.focusedWindow();
    local f = win:frame();
    local screen = win:screen();
    local max = screen:frame();

    f.x = max.x;
    f.y = max.y;
    f.w = max.w;
    f.h = max.h;
    win:setFrame(f);
end)
--[[window resize end]]
--[[--  快捷键：窗口移动
--]]
--[[window move begin]]
local function _window_move_to_screen(how)
    local win = hs.window.focusedWindow();
    if win == nil then
        hs.alert.show("Error: 没有当前窗口");
        return;
    end
    if how == "Left" then
        hs.alert.show("窗口左移");
        win:moveOneScreenWest();
    elseif how == "Right" then
        hs.alert.show("窗口右移");
        win:moveOneScreenEast();
    elseif how == "Up" then
        hs.alert.show("窗口上移");
        win:moveOneScreenNorth();
    elseif how == "Down" then
        hs.alert.show("窗口下移");
        win:moveOneScreenSouth();
    end

end

local _window_move_key_mapping = {
    window_move_to_screen_left = { _SUPER_META, "Left" },
    window_move_to_screen_right = { _SUPER_META, "Right" },
    window_move_to_screen_up = { _SUPER_META, "Up" },
    window_move_to_screen_down = { _SUPER_META, "Down" },
};

local _window_move_action_mapping = {
    window_move_to_screen_left = hs.fnutils.partial(_window_move_to_screen, "Left"),
    window_move_to_screen_right = hs.fnutils.partial(_window_move_to_screen, "Right"),
    window_move_to_screen_up = hs.fnutils.partial(_window_move_to_screen, "Up"),
    window_move_to_screen_down = hs.fnutils.partial(_window_move_to_screen, "Down"),
};

hs.spoons.bindHotkeysToSpec(_window_move_action_mapping, _window_move_key_mapping);
--[[window move end]]