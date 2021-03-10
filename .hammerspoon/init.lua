--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)

--  TODO: 快捷键 2次按键 切换窗口所在的 screen
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
    { "MWeb" },
    { "Notes" },
    { "Preview" },
    { "Terminal" },
    { "Visual Studio Code", "/Applications/Visual Studio Code.app", "com.microsoft.VSCode" },
    { "WeChat" },
    { "Xcode" },
    { "XMind" },
    { "企业微信", "/Applications/企业微信.app", "com.tencent.WeWorkMac" },
};
--[[配置快捷键和对应的功能
    1. 启动应用: 只需要配置快捷键和 _AppMetaArray 中配置的应用名称
]]
local _HotkeyMap = {
    tab = { _SUPER_META, nil, hs.hints.windowHints },

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
    m = { _SUPER_META, "MWeb" },
    n = { _SUPER_META, "Numbers" },
    o = {},
    p = { _SUPER_META, "Preview" },
    q = {},
    r = { _SUPER_META, "Calendar" },
    s = { _SUPER_META, "Visual Studio Code" },
    t = { _SUPER_META, "Terminal" },
    u = { _SUPER_META, "企业微信" },
    v = { _SUPER_META, "MacVim" },
    w = { _SUPER_META, "WeChat" },
    x = { _SUPER_META, "Xcode" },
    y = {},
    z = { _SUPER_META, "XMind" },
};

--  创建一个定时器来加载其它配置, 防止脚本出错导致 ReloadConfiguration 配置加载失败
hs.timer.new(0, function()

    local Meteor = require("meteor");
    local UnitedHotkey = Meteor.UnitedHotkey;

    for k, v in pairs(_AppMetaArray) do
        if (v and #v > 0) then
            UnitedHotkey.ActionMap[v[1]] = { v[1], function()
                Meteor.Application.SwitchTo(table.unpack(v));
            end };
        end
    end

    UnitedHotkey.BindSpecMap(_HotkeyMap);
end):start();
--[[快捷键配置表，配置项格式: <key> = {快捷键描述1, 快捷键描述2, ...}

每个快捷键描述为一个数组，格式为: {<修饰键数组>, {功能描述1, 功能描述2, ...}.
每个功能描述为一个数组，格式为: {<功能说明>, <功能函数名>[, arg1[, arg2[, ...] ] ]}.
可用的功能函数:
    toogle_application: 启动或显示某应用界面. args:
        - arg1<required>: 应用名称, 用来做界面显示; 当应用没启动时, 也可能用来启动应用
        - arg2[optional]: 应用绝对路径, 用来定位不同版本的的同名应用
        - arg3[optional]: bundleID, 用来查找运行中的应用

    move_window: 移动当前焦点窗口的位置或改变大小. args:
        - arg1<required>: 窗口所在屏幕的网格划分, 比如 "2x2" 把屏幕划分为2列2行
        - arg2[optional]: 窗口要设置的网格描述, 比如 "0,0 1x1" 为把窗口移动到网格的左上角划分区域
]]
local _log = hs.logger.new("my_config", "debug");
local _SHORTCUT_KEYS = {
    ["1"] = { _SUPER_META, {} },
    ["2"] = { _SUPER_META, {} },
    ["3"] = { _SUPER_META, {} },
    ["4"] = { _SUPER_META, {} },
    ["5"] = { _SUPER_META, {} },
    ["6"] = { _SUPER_META, {} },
    ["7"] = { _SUPER_META, {} },
    ["8"] = { _SUPER_META, {} },
    ["9"] = { _SUPER_META, {
        { "Customize", "move_window", "6x4" },
        { "LH(left half)", "move_window", "2x1", "0,0, 1x1" },
        { "RH(right half)", "move_window", "2x1", "1,0, 1x1" },
        { "TH(top half)", "move_window", "1x2", "0,0, 1x1" },
        { "BH(bottom half)", "move_window", "1x2", "0,1, 1x1" },
    } },
    ["0"] = { _SUPER_META, { {nil, "toogle_max_screen_size" } } },
};
hs.window.animationDuration = 0;
hs.window.setFrameCorrectness = true;

local _ACTIONS = {};
local _cloasable_alert;
local function _do_action(actionInfo)
    if (type(actionInfo) == "table" and #actionInfo > 1) then
        local func = _ACTIONS[actionInfo[2]];
        if (func) then
            func(table.unpack(actionInfo, 3));
        else
            hs.alert("未定义行为: " .. actionInfo[2]);
        end
    end
end
--  遍历 _SHORTCUT_KEYS, 绑定所有快捷键
for k, v in pairs(_SHORTCUT_KEYS) do
    if (type(v) == "table" and (#v == 2) and (type(v[1]) == "table") and (type(v[2]) == "table")) then
        local actionInfos = v[2];
        local invalidActionInfoCount = 0;
        for _, t in pairs(actionInfos) do
            if (type(t) ~= "table") then
                _log.e(string.format("_SHORTCUT_KEYS config for key('%s') has invalud action config: %s", k, t));
                invalidActionInfoCount = invalidActionInfoCount + 1;
            end
        end
        if (invalidActionInfoCount == 0) then
            hs.hotkey.bind(v[1], k, function()
                if (#actionInfos == 0) then
                    hs.alert("快捷键未绑定功能");
                elseif (#actionInfos == 1) then
                    _do_action(actionInfos[1]);
                else
                    local choices = {};
                    for i, info in pairs(actionInfos) do
                        if (info[2]) then
                            table.insert(choices, {
                                actionInfo = info,
                                subText = table.concat(info, ", ", info[1] and 2 or 3),
                                text = info[1] or info[2],
                            });
                        end
                    end
                    hs.chooser.new(function(result)
                        if (result) then
                            _do_action(result.actionInfo);
                        end
                    end)
                    :choices(choices)
                    :show();
                end
            end, function()
                if (_cloasable_alert) then
                    hs.alert.closeSpecific(_cloasable_alert);
                    _cloasable_alert = nil;
                end
            end);
        end
    end
end

--[[移动当前焦点窗口的位置或改变大小. args:
        - gridPartition<required>: 窗口所在屏幕的网格划分, 比如 "2x2" 把屏幕划分为2行2列
        - gridDescribe[optional]: 窗口要设置的网格描述, 比如 "0,0 1x1" 为把窗口移动到网格的左上角划分区域
]]
_ACTIONS.move_window = function(gridPartition, gridDescribe)
    if (type(gridPartition) ~= "string" or (gridDescribe and type(gridDescribe) ~= "string")) then
        _log.e(string.format("move_window invalid args(gridPartition: %s, gridDescribe: %s)", gridPartition, gridDescribe));
        return;
    end
    local wind = hs.window.focusedWindow() or hs.window.frontmostWindow();
    if (wind == nil) then
        hs.alert("没有当前窗口");
        return;
    end
    _log.d(string.format("move_window(%s)'%s' in gridPartation '%s'",
    wind:title(),
    gridDescribe and string.format(" to '%s'", gridDescribe) or "",
    gridPartition
    ));
    hs.grid.setGrid(gridPartition);
    if (gridDescribe) then
        if (wind:isMaximizable()) then
            hs.grid.set(wind, gridDescribe);
            hs.alert("改变窗口: " .. wind:title());
            hs.mouse.setAbsolutePosition(wind:frame().center);
        else
            local from = wind:frame().center;
            local to = hs.geometry.copy(hs.grid.getCell(gridDescribe, wind:screen())).center;
            wind:move(hs.geometry.point(to.x - from.x, to.y - from.y));
            hs.alert("移动窗口: " .. wind:title());
            hs.mouse.setAbsolutePosition(to);
        end
    else
        hs.grid.show(function()
            hs.alert((wind:isMaximizable() and "改变窗口: " or "移动窗口: ") .. wind:title());
            hs.mouse.setAbsolutePosition(wind:frame().center);
        end, false);
    end
end

--[[切换当前焦点窗口的满屏和当前大小, 当窗口不可以改变大小时, 行为变为切换窗口的当前位置和中间位置]]
local _saved_window_frame = {};
_ACTIONS.toogle_max_screen_size = function()
    local wind = hs.window.focusedWindow() or hs.window.frontmostWindow();
    if (wind == nil) then
        hs.alert("没有当前窗口");
        return;
    end
    local windID = wind:id();
    local oldFrame = _saved_window_frame[windID];
    if (oldFrame) then
        wind:move(oldFrame);
        _saved_window_frame[windID] = nil;
    else
        if (windID) then
            _saved_window_frame[windID] = wind:frame();
        end
        if (wind:isMaximizable()) then
            wind:maximize();
        else
            wind:centerOnScreen();
        end
        hs.mouse.setAbsolutePosition(wind:frame().center);
    end
end