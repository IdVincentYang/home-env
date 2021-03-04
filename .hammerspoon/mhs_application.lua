local Class = require("c3class");

local _CLASS_NAME = "Application";
local _L = hs.logger.new(_CLASS_NAME, 5);

local Application = Class(_CLASS_NAME);

--[[切换当前应用到指定应用

- 如果应用没有启动, 则启动此应用
- 如果应用已启动, 则把应用激活为当前应用
    - 如果当前应用没有窗口, 则退出函数
    - 如果当前应用有可显示的窗口, 但隐藏了, 则把所有窗口显示出来
    - 如果当前应用有获得焦点的窗口, 则把鼠标指针移动到焦点窗口中间

- TODO: 当激活应用后,如果鼠标指针已经在窗口区域内,则不再设置鼠标位置
]]
Class.Static(Application, "SwitchTo", function(name, path, bundleID)
    if (type(name) ~= "string" or string.len(name) == 0) then
        _L.e("SwitchTo invalid arg 'name': " .. name);
        return;
    end
    if (path and (type(path) ~= "string" or string.len(path) == 0)) then
        _L.e("SwitchTo invalid arg 'path': " .. path);
        return;
    end
    if (bundleID and (type(bundleID) ~= "string" or string.len(bundleID) == 0)) then
        _L.e("SwitchTo invalid arg 'bundleID': " .. bundleID);
        return;
    end

    local app = hs.application.find(bundleID or name);
    if (not app) then
        --  没有找到此应用, 启动它
        if (hs.application.launchOrFocus(path or name)) then
            _L.d("启动应用: " .. name);
        else
            _L.e("启动应用失败: " .. name .. (path and string.format("(%s)", path) or ""));
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
        else
            _L.df("应用 %s 无活动窗口", app:name());
        end
    end
end);

return Application;