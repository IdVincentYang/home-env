--[[--
--  [Getting Started](http://www.hammerspoon.org/go/)
--  [API Docs](https://www.hammerspoon.org/docs/)
--  [Spoons Download](https://www.hammerspoon.org/Spoons/)
--]]
local _SUPER_META = { "cmd", "alt", "ctrl", "shift" };
hs.hotkey.bind(_SUPER_META, "tab", hs.hints.windowHints);
--[[快捷键配置表，配置项格式: <key> = {快捷键描述1, 快捷键描述2, ...}

每个快捷键描述为一个数组，格式为: {<修饰键数组>, {功能描述1, 功能描述2, ...}.
每个功能描述为一个数组，格式为: {<功能说明>, <功能函数名>[, arg1[, arg2[, ...] ] ]}.
可用的功能函数:
    toogle_application: 启动或显示某应用界面. args:
        - arg1<required>: 应用名称
        - arg2[optional]: 应用绝对路径或bundleID, 如果没有, 则根据应用名称来查找应用

    move_window: 移动当前焦点窗口的位置或改变大小. args:
        - arg1<required>: 窗口所在屏幕的网格划分, 比如 "2x2" 把屏幕划分为2列2行
        - arg2[optional]: 窗口要设置的网格描述, 比如 "0,0 1x1" 为把窗口移动到网格的左上角划分区域
]]
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
    a = { _SUPER_META, { {nil, "toogle_application", "Android Studio" } } },
    b = { _SUPER_META, { {nil, "toogle_application", "" } } },
    c = { _SUPER_META, { {nil, "toogle_application", "CocosCreator" } } },
    d = { _SUPER_META, { {nil, "toogle_application", "" } } },
    e = { _SUPER_META, { {nil, "toogle_application", "GitKraken" } } },
    f = { _SUPER_META, { {nil, "toogle_application", "Finder" } } },
    g = { _SUPER_META, { {nil, "toogle_application", "Google Chrome" } } },
    h = { _SUPER_META, { {nil, "toogle_application", "" } } },
    i = { _SUPER_META, { {nil, "toogle_application", "" } } },
    --  j = { _SUPER_META, { nil,{ "toogle_application", "" } } },
    k = { _SUPER_META, { {nil, "toogle_application", "" } } },
    --  l 被重载快捷键占用
    m = { _SUPER_META, { {nil, "toogle_application", "MWeb" } } },
    n = { _SUPER_META, {
        --  { "Notes","toogle_application", "Notes" },
        { "Numbers", "toogle_application", "Numbers" },
    } },
    o = { _SUPER_META, { {nil, "toogle_application", "" } } },
    p = { _SUPER_META, {
        { "Preview", "toogle_application", "Preview" },
        { "Paradigm", "toogle_application", "Visual Paradigm" },
    } },
    q = { _SUPER_META, { {nil, "toogle_application", "" } } },
    r = { _SUPER_META, { {nil, "toogle_application", "Calendar" } } },
    s = { _SUPER_META, { {nil, "toogle_application", "Visual Studio Code", "com.microsoft.VSCode" } } },
    t = { _SUPER_META, { {nil, "toogle_application", "Terminal" } } },
    u = { _SUPER_META, { {nil, "toogle_application", "企业微信", "com.tencent.WeWorkMac" } } },
    v = { _SUPER_META, { {nil, "toogle_application", "MacVim" } } },
    w = { _SUPER_META, { {nil, "toogle_application", "WeChat" } } },
    x = { _SUPER_META, { {nil, "toogle_application", "Xcode" } } },
    y = { _SUPER_META, {} },
    z = { _SUPER_META, { {nil, "toogle_application", "XMind" } } },
};
hs.window.animationDuration = 0;
hs.window.setFrameCorrectness = true;

local _log = hs.logger.new("my_config", "debug");
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

--[[启动或显示某应用界面. args:
        name: 应用名称
        pathOrBundleID: 应用绝对路径或 bundleID
]]
_ACTIONS.toogle_application = function(name, pathOrBundleID)
    local appHint = pathOrBundleID or name
    if (type(appHint) ~= "string" or string.len(appHint) == 0) then
        _log.e(string.format("toogle_application invalid args(name: %s, pathOrBundleID: %s)", name, pathOrBundleID));
        return;
    end
    local app = hs.application.find(appHint);
    if (not app) then
        --  没有找到此应用, 启动它
        if (hs.application.launchOrFocus(appHint)) then
            hs.alert("启动应用: " .. appHint);
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
            _cloasable_alert = hs.alert.show(name);
        else
            hs.alert(string.format("应用 %s 无活动窗口", app:name()));
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
    local windTitle = wind:title();
    local oldFrame = _saved_window_frame[windTitle];
    if (oldFrame) then
        wind:move(oldFrame);
        _saved_window_frame[windTitle] = nil;
    else
        if (windTitle) then
            _saved_window_frame[windTitle] = wind:frame();
        end
        if (wind:isMaximizable()) then
            wind:maximize();
        else
            wind:centerOnScreen();
        end
        hs.mouse.setAbsolutePosition(wind:frame().center);
    end
end