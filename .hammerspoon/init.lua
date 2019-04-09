--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)
--]]
local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };
local _log = hs.logger.new("my_config", "debug");

--[[--
--  快捷键：窗口移动
--]]
--[[window move begin]]
local function _get_menu_bar_height()
    return hs.screen.primaryScreen():frame().y;
end
local function _window_move_in_screen(direction, division, duration)
    local win = hs.window.focusedWindow();
    if win == nil then
        hs.alert.show("Error: 没有当前窗口");
        return;
    end

    local w = win:frame();
    local s = win:screen():frame();
    local dt = _get_menu_bar_height();
    local inPos = nil;

    -- 窗口在预定位置，连续移动，否则设置为初始位置
    if (direction == "centered") then
        local d = hs.geometry.size(math.floor(s.w / division), math.floor(s.h / division));
        local c = hs.geometry.point(math.floor((s.x + s.w) / 2), math.floor((s.y + s.h) / 2));
        local isCenter = math.abs(w:distance(c)) < dt;
        local fitSize = (w.w % d.w < dt) and (w.h % d.h < dt);
        inPos = isCenter and fitSize;
        w.size = d:scale(inPos and (math.floor(w.w / d.w) % division + 1) or division);
        w.center = s.center;
    elseif (direction == "horizontal") then
        local d = hs.geometry.size(math.floor(s.w / division), s.h);
        local fitSize = (math.abs(w.w - d.w) < dt) and (math.abs(w.h - d.h) < dt);
        inPos = fitSize and ((w.x - s.x) % d.w) == 0;
        w.x = inPos and ((w.x + d.w) % (d.w * division)) or s.x;
        w.y = s.y;
        w.size = d;
    elseif (direction == "vertical") then
        local d = hs.geometry.size(s.w, math.floor(s.h / division));
        local fitSize = (math.abs(w.w - d.w) < dt) and (math.abs(w.h - d.h) < dt);
        inPos = fitSize and ((w.y - s.y) % d.h) == 0;
        w.x = s.x;
        w.y = inPos and ((w.y + d.h) % (d.h * division)) or s.y;
        w.size = d;
    elseif (direction == "slash") then
        local d = hs.geometry.size(math.floor(s.w / division), math.floor(s.h / division));
        local onGrid = ((w.x - s.x) % d.w) == 0 and ((w.y - s.y) % d.h) == 0;
        local fitSize = (math.abs(w.w - d.w) < dt) and (math.abs(w.h - d.h) < dt);
        inPos = onGrid and fitSize and (math.abs(w.x - w.y) > (d.w + d.h) / 2);
        w.x = inPos and ((w.x - d.w) % (d.w * division)) or (s.x + d.w * (division - 1));
        w.y = inPos and ((w.y + d.h) % (d.h * division)) or s.y;
        w.size = d;
    elseif (direction == "backslash") then
        local d = hs.geometry.size(math.floor(s.w / division), math.floor(s.h / division));
        local onGrid = ((w.x - s.x) % d.w) == 0 and ((w.y - s.y) % d.h) == 0;
        local fitSize = (math.abs(w.w - d.w) < dt) and (math.abs(w.h - d.h) < dt);
        inPos = onGrid and fitSize and (math.abs(w.x - w.y) < math.min(d.w, d.h) / 2);
        w.x = inPos and ((w.x + d.w) % (d.w * division)) or s.x;
        w.y = inPos and ((w.y + d.h) % (d.h * division)) or s.y;
        w.size = d;
    else
        hs.alert.show("Error: 不支持此移动模式："..direction);
        return;
    end
    _log:d("%s{inPos: %s, w: %s}", direction, tostring(inPos), tostring(w));
    win:setFrameWithWorkarounds(w, duration);
end

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

local _window_move_hotkey_mapping = {
    window_move_in_center = { _SUPER_META, "1" },
    window_move_in_screen_horizontal = { _SUPER_META, "2" },
    window_move_in_screen_vertical = { _SUPER_META, "3" },
    window_move_in_screen_slash = { _SUPER_META, "4" },
    window_move_in_screen_backslash = { _SUPER_META, "5" },
    window_move_to_screen_left = { _SUPER_META, "Left" },
    window_move_to_screen_right = { _SUPER_META, "Right" },
    window_move_to_screen_up = { _SUPER_META, "Up" },
    window_move_to_screen_down = { _SUPER_META, "Down" },
};

local _window_move_action_mapping = {
    window_move_in_center = hs.fnutils.partial(_window_move_in_screen, "centered", 3, 0),
    window_move_in_screen_horizontal = hs.fnutils.partial(_window_move_in_screen, "horizontal", 2, 0),
    window_move_in_screen_vertical = hs.fnutils.partial(_window_move_in_screen, "vertical", 2, 0),
    window_move_in_screen_slash = hs.fnutils.partial(_window_move_in_screen, "slash", 2, 0),
    window_move_in_screen_backslash = hs.fnutils.partial(_window_move_in_screen, "backslash", 2, 0),
    window_move_to_screen_left = hs.fnutils.partial(_window_move_to_screen, "Left"),
    window_move_to_screen_right = hs.fnutils.partial(_window_move_to_screen, "Right"),
    window_move_to_screen_up = hs.fnutils.partial(_window_move_to_screen, "Up"),
    window_move_to_screen_down = hs.fnutils.partial(_window_move_to_screen, "Down"),
};

hs.spoons.bindHotkeysToSpec(_window_move_action_mapping, _window_move_hotkey_mapping);
--[[window move end]]