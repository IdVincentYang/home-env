--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)
--]]
local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };
--[[快捷键配置表，配置项格式: <key> = {快捷键描述1, 快捷键描述2, ...}

每个快捷键描述为一个数组，格式为: {<修饰键数组>, {功能描述1, 功能描述2, ...}.
每个功能描述为一个数组，格式为: {<功能函数名>[, arg1[, arg2[, ...] ] ]}.
可用的功能函数:
    toogle_application: 启动或显示某应用界面. args:
        arg1: 应用名称,应用绝对路径或bundleID
]]
local _SHORTCUT_KEYS = {
    a = { _SUPER_META, { { "toogle_application", "Android Studio" } } },
    b = { _SUPER_META, { { "toogle_application", "" } } },
    c = { _SUPER_META, { { "toogle_application", "CocosCreator" } } },
    d = { _SUPER_META, { { "toogle_application", "" } } },
    e = { _SUPER_META, { { "toogle_application", "GitKraken" } } },
    f = { _SUPER_META, { { "toogle_application", "Finder" } } },
    g = { _SUPER_META, { { "toogle_application", "Google Chrome" } } },
    h = { _SUPER_META, { { "toogle_application", "" } } },
    i = { _SUPER_META, { { "toogle_application", "" } } },
    j = { _SUPER_META, { { "toogle_application", "" } } },
    k = { _SUPER_META, { { "toogle_application", "" } } },
    l = { _SUPER_META, { { "toogle_application", "" } } },
    m = { _SUPER_META, { { "toogle_application", "MWeb" } } },
    n = { _SUPER_META, { { "toogle_application", "Notes" } } },
    o = { _SUPER_META, { { "toogle_application", "" } } },
    p = { _SUPER_META, { { "toogle_application", "Preview" } } },
    q = { _SUPER_META, { { "toogle_application", "" } } },
    r = { _SUPER_META, { { "toogle_application", "Calendar" } } },
    s = { _SUPER_META, { { "toogle_application", "com.microsoft.VSCode" } } },
    t = { _SUPER_META, { { "toogle_application", "Terminal" } } },
    u = { _SUPER_META, { { "toogle_application", "WeCom" } } },
    v = { _SUPER_META, { { "toogle_application", "MacVim" } } },
    w = { _SUPER_META, { { "toogle_application", "WeChat" } } },
    x = { _SUPER_META, { { "toogle_application", "Xcode" } } },
    y = { _SUPER_META, { { "toogle_application", "Visual Paradigm" } } },
    z = { _SUPER_META, { { "toogle_application", "XMind" } } },
};

local _log = hs.logger.new("my_config", "debug");
local _ACTIONS = {};
--  遍历 _SHORTCUT_KEYS, 绑定所有快捷键
for k, v in pairs(_SHORTCUT_KEYS) do
    if (type(v) == "table" and #v > 1) then
        local actionInfos = v[2];
        if (type(actionInfos) == "table" and #actionInfos > 0) then
            hs.hotkey.bind(v[1], k, function()
                local actionCounts = #actionInfos;
                if (actionCounts == 1) then
                    local actionInfo = actionInfos[1];
                    if (type(actionInfo) == "table" and #actionInfo > 0) then
                        local func = _ACTIONS[actionInfo[1]];
                        if (func) then
                            func(table.unpack(actionInfo, 2));
                        else
                            hs.alert("未定义行为: " .. actionInfo[1]);
                        end
                    end
                end
            end)
        end
    end
end

--[[启动或显示某应用界面. args:
        appHint: 应用名称,应用绝对路径或bundleID
]]
_ACTIONS.toogle_application = function(appHint)
    if (type(appHint) ~= "string" or string.len(appHint) == 0) then
        _log.e("toogle_application invalid args: appHint: " .. appHint);
        return;
    end
    local app = hs.application.find(appHint)
    if (not app) then
        --  没有找到此应用, 启动它
        app = hs.application.open(appHint)
        if (hs.application.launchOrFocus(appHint)) then
            hs.alert("启动应用: " .. appHint);
            _log.d(hs.application.frontmostApplication():bundleID());
        else
            hs.alert("启动应用失败: " .. appHint);
        end
    else
        --  如果此应用不是前台应用，激活它
        if (not app:isFrontmost()) then
            app:activate(true);
        end
        local focusedWin = app:focusedWindow();
        --  如果此应用没有有焦点的窗口,但是有窗口,则激活一下
        if (not focusedWin and #app:allWindows() > 0) then
            hs.application.launchOrFocus(appHint);
            focusedWin = app:focusedWindow();
        end
        -- 如果此应用有焦点窗口, 移动鼠标到窗口中间
        if (focusedWin) then
            hs.mouse.setAbsolutePosition(focusedWin:frame().center);
            hs.alert.show(appHint);
        end
    end
end

--[[--
--  快捷键：窗口移动
--]]
--[[window move begin]]
--  数 a 接近数 b 的整数倍
local function _number_near_multiple(a, b, dt)
    local mod = math.fmod(a, b);
    return (math.abs(mod) <= dt) or (math.abs(mod - b) <= dt)
end

local function _get_menu_bar_height()
    return hs.screen.primaryScreen():frame().y;
end

local function _window_move_in_screen(direction, division, duration)
    _log.d(string.format(
    "_window_move_in_screen(direction: %s, division: %d, duration: %d)",
    direction,
    division,
    duration
    ));
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
        local c = hs.geometry.point(math.floor(w.x + w.w / 2), math.floor(w.y + w.h / 2));
        local isCenter = math.abs(w:distance(c)) <= dt;
        local fitSize = _number_near_multiple(w.w, d.w, dt) and _number_near_multiple(w.h, d.h, dt);
        inPos = isCenter and fitSize;
        w.size = d:scale(inPos and (math.floor((w.w + dt) / d.w) % division + 1) or division);
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
    _log:d(string.format("%s{inPos: %s, w: %s}", direction, tostring(inPos), tostring(w)));
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