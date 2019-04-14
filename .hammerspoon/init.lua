--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)
--]]
local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };
local _log = hs.logger.new("my_config", "debug");

--[[--
--  快捷键：启动应用
--]]
--[[launch application begin]]
local _application_launch_action_mapping = {};
local _application_launch_hotkey_mapping = {};

--[[    启动路径指定的应用并把鼠标移上去
--]]
local function _launch_app(path)
    if (hs.application.launchOrFocus(path)) then
        local app = hs.application.frontmostApplication();
        if (app and app:path():match(path)) then
            local win = app:focusedWindow();
            if (win) then
                hs.mouse.setAbsolutePosition(win:frame().center);
            end
        end
        app:activate(true); --  前置所有窗口
    else
        hs.alert("找不到应用: " .. path);
    end
end

local function _add_app(hotkey, name, path)
    local key = "app_launch_" .. name;
    _application_launch_action_mapping[key] = hs.fnutils.partial(_launch_app, path);
    _application_launch_hotkey_mapping[key] = { _SUPER_META, hotkey };
end

_add_app("a", "android_studio", "/Applications/Android Studio.app");
_add_app("c", "cocos_creator", "/Applications/CocosCreator.app");
_add_app("e", "git_kraken", "/Applications/GitKraken.app");
_add_app("f", "finder", "/System/Library/CoreServices/Finder.app");
_add_app("g", "google_chrome", "/Applications/Google Chrome.app");
_add_app("k", "google_keep", "~/Applications/Chrome Apps.localized/Default hmjkmjkepdijhoojdojkdfohbdgmmhki.app");
_add_app("m", "mweb", "/Applications/MWeb.app");
_add_app("n", "notes", "/Applications/Notes.app");
_add_app("p", "preview", "/Applications/Preview.app");
_add_app("r", "calendar", "/Applications/Calendar.app");
_add_app("s", "visual_studio_code", "/Applications/Visual Studio Code.app");
_add_app("t", "terminal", "/Applications/Utilities/Terminal.app");
_add_app("v", "mac_vim", "/Applications/MacVim.app");
_add_app("w", "we_chat", "/Applications/WeChat.app");
_add_app("x", "xcode", "/Applications/Xcode.app");
_add_app("y", "visual_paradigm", "/Applications/Visual Paradigm.app");
_add_app("z", "xmind", "/Applications/XMind.app");

hs.spoons.bindHotkeysToSpec(_application_launch_action_mapping, _application_launch_hotkey_mapping);
--[[launch application end]]
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
        hs.alert.show("Error: 不支持此移动模式：" .. direction);
        return;
    end
    _log:d("%s{inPos: %s, w: %s}", direction, tostring(inPos), tostring(w));
    win:setFrameWithWorkarounds(w, duration);
    hs.mouse.setAbsolutePosition(win:frame().center);
end

local function _window_move_to_screen(how, duration)
    local win = hs.window.focusedWindow();
    if win == nil then
        hs.alert.show("Error: 没有当前窗口");
        return;
    end
    local currScreen = win:screen();
    local nextScreen, tipMsg;
    if how == "Left" then
        tipMsg = "窗口左移";
        nextScreen = currScreen:toWest();
    elseif how == "Right" then
        tipMsg = "窗口右移";
        nextScreen = currScreen:toEast();
    elseif how == "Up" then
        tipMsg = "窗口上移";
        nextScreen = currScreen:toNorth();
    elseif how == "Down" then
        tipMsg = "窗口下移";
        nextScreen = currScreen:toSouth();
    end
    if (currScreen ~= nextScreen) then
        win:moveToScreen(nextScreen, nil, nil, duration);
        hs.mouse.setAbsolutePosition(win:frame().center);
        if (tipMsg ~= nil) then
            hs.alert.show(tipMsg);
        end
    end
end

local _window_move_action_mapping = {
    window_move_in_center = hs.fnutils.partial(_window_move_in_screen, "centered", 3, 0),
    window_move_in_screen_horizontal = hs.fnutils.partial(_window_move_in_screen, "horizontal", 2, 0),
    window_move_in_screen_vertical = hs.fnutils.partial(_window_move_in_screen, "vertical", 2, 0),
    window_move_in_screen_slash = hs.fnutils.partial(_window_move_in_screen, "slash", 2, 0),
    window_move_in_screen_backslash = hs.fnutils.partial(_window_move_in_screen, "backslash", 2, 0),
    window_move_to_screen_left = hs.fnutils.partial(_window_move_to_screen, "Left", 0),
    window_move_to_screen_right = hs.fnutils.partial(_window_move_to_screen, "Right", 0),
    window_move_to_screen_up = hs.fnutils.partial(_window_move_to_screen, "Up", 0),
    window_move_to_screen_down = hs.fnutils.partial(_window_move_to_screen, "Down", 0),
};

local _window_move_hotkey_mapping = {
    window_move_in_center = { _SUPER_META, "0" },
    window_move_in_screen_horizontal = { _SUPER_META, "9" },
    window_move_in_screen_vertical = { _SUPER_META, "8" },
    window_move_in_screen_slash = { _SUPER_META, "7" },
    window_move_in_screen_backslash = { _SUPER_META, "6" },
    window_move_to_screen_left = { _SUPER_META, "Left" },
    window_move_to_screen_right = { _SUPER_META, "Right" },
    window_move_to_screen_up = { _SUPER_META, "Up" },
    window_move_to_screen_down = { _SUPER_META, "Down" },
};

hs.spoons.bindHotkeysToSpec(_window_move_action_mapping, _window_move_hotkey_mapping);
--[[window move end]]
