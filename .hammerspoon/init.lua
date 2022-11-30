--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)

--  TODO: 字典查找功能 https://github.com/sugood/hammerspoon/blob/master/modules/dict.lua
--  TODO: 提供所有 action 的按名字搜索功能
--]]
hs.console.clearConsole();
hs.loadSpoon("ReloadConfiguration");
spoon.ReloadConfiguration:start();

local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };
--[[列出准备使用快捷键切换应用的备选应用信息列表
--  1. required: 应用名, 不包含路径和扩展名
--  2. optional: 应用绝对路径，当存在多个同名程序时用来决定启动哪个程序
--  3. optional: 应用的 BundleID, 当应用启动后在菜单栏显示的名字和第一项的名称不一样时使用
]]
local _AppMetaArray = {
    { "Android Studio" },
    { "Calendar" },
    { "CocosCreator" },
    { "Finder" },
    { "GitKraken" },
    { "Google Chrome" },
    { "Numbers" },
    { "MacVim" },
    { "MWeb Pro" },
    { "Notes" },
    { "Preview" },
    { "Terminal" },
    { "Warp" },
    { "Visual Studio Code", "/Applications/Visual Studio Code.app", "com.microsoft.VSCode" },
    { "WeChat" },
    { "Xcode" },
    { "XMind" },
    { "企业微信", "/Applications/企业微信.app", "com.tencent.WeWorkMac" },
};

--[[配置快捷键和对应的功能
    1. 启动应用: 只需要配置快捷键和 _AppMetaArray 中配置的应用名称
]]
local Action = {};
local _HotkeyMap = {
    tab = { _SUPER_META, nil, hs.hints.windowHints },

    down = { _SUPER_META, nil, function() Action.MoveOneScreen("down"); end },
    left = { _SUPER_META, nil, function() Action.MoveOneScreen("left"); end },
    right = { _SUPER_META, nil, function() Action.MoveOneScreen("right"); end },
    up = { _SUPER_META, nil, function() Action.MoveOneScreen("up"); end },

    ["9"] = { _SUPER_META, "meteor_window_move_by_grid" },
    ["0"] = { _SUPER_META, "meteor_window_toggle_maxsize" },

    a = { _SUPER_META, "Android Studio" },
    b = {},
    c = { _SUPER_META, "CocosCreator" },
    d = {},
    e = { _SUPER_META, "GitKraken" },
    f = { _SUPER_META, "Finder" },
    g = { _SUPER_META, "Google Chrome" },
    h = {},
    i = {},
    j = {},
    k = {},
    l = {},
    m = { _SUPER_META, "MWeb Pro" },
    n = { _SUPER_META, "Numbers" },
    o = {},
    p = { _SUPER_META, "Preview" },
    q = {},
    r = { _SUPER_META, "Calendar" },
    s = { _SUPER_META, "Visual Studio Code" },
    t = { _SUPER_META, "Warp" },
    u = { _SUPER_META, "企业微信" },
    v = { _SUPER_META, "MacVim" },
    w = { _SUPER_META, "WeChat" },
    x = { _SUPER_META, "Xcode" },
    y = {},
    z = { _SUPER_META, "XMind" },
};

hs.window.animationDuration = 0;
hs.window.setFrameCorrectness = true;

--  创建一个定时器来加载其它配置, 防止脚本出错导致 ReloadConfiguration 配置加载失败
hs.timer.new(0, function()
    local _L = hs.logger.new("init", 5);

    local Meteor = require("meteor");
    local UnitedHotkey = Meteor.UnitedHotkey;

    UnitedHotkey.ActionMap["meteor_window_move_by_grid"] = { "Move Window...", function()
        local wind = hs.window.focusedWindow() or hs.window.frontmostWindow();
        if (wind == nil) then
            hs.alert("没有当前窗口");
            return;
        end
        Meteor.Window.MoveByGrid(wind, "6x4");
    end };

    UnitedHotkey.ActionMap["meteor_window_toggle_maxsize"] = {nil, function()
        local wind = hs.window.focusedWindow() or hs.window.frontmostWindow();
        if (wind == nil) then
            hs.alert("没有当前窗口");
            return;
        end
        Meteor.Window.ToggleMaxsizeOrCenterPosition(wind);
    end };

    for k, v in pairs(_AppMetaArray) do
        if (v and #v > 0) then
            UnitedHotkey.ActionMap[v[1]] = { v[1], function()
                Meteor.Application.SwitchTo(table.unpack(v));
            end };
        end
    end

    -- 朝某个方向移动当前窗口一屏
    function Action.MoveOneScreen(direction)
        local wind = hs.window.focusedWindow();
        if (wind == nil) then
            hs.alert("没有当前窗口");
        else
            if (direction == "left") then
                wind:moveOneScreenWest();
            elseif (direction == "right") then
                wind:moveOneScreenEast();
            elseif (direction == "up") then
                wind:moveOneScreenNorth();
            elseif (direction == "down") then
                wind:moveOneScreenSouth();
            else
                _L.w("_MoveOneScreen invalid argument: " .. direction);
            end
            hs.mouse.absolutePosition(wind:frame().center);
        end
    end

    UnitedHotkey.BindSpecMap(_HotkeyMap);
end):start();
