local Class = require("c3class");

local _CLASS_NAME = "Window";
local _L = hs.logger.new(_CLASS_NAME, 5);

local Window = Class(_CLASS_NAME);

--[[在屏幕之间移动窗口, 改变窗口在屏幕中的位置和尺寸, 同时移动鼠标指针到窗口中心

--  wind<required>: 要移动的窗口
--  part<required>: 当前屏幕的 grid 划分
--  desc[optional]: 目的位置的 grid 描述
]]
Class.Static(Window, "MoveByGrid", function(wind, part, desc)
    hs.grid.setGrid(part);
    if (desc) then
        if (wind:isMaximizable()) then
            hs.grid.set(wind, desc);
            hs.mouse.setAbsolutePosition(wind:frame().center);
        else
            local from = wind:frame().center;
            local to = hs.geometry.copy(hs.grid.getCell(desc, wind:screen())).center;
            wind:move(hs.geometry.point(to.x - from.x, to.y - from.y));
            hs.mouse.setAbsolutePosition(to);
        end
    else
        hs.grid.show(function()
            hs.mouse.setAbsolutePosition(wind:frame().center);
        end, false);
    end
    return wind;
end);

Class.Static(Window, "_saved_window_frame", {});
--[[窗口在当前大小/位置和满屏/居中切换

--  当窗口可改变大小时, 在当前大小和满屏间切换
--  当窗口不可改变大小时, 在当前位置和剧中位置切换

--  wind<required>: 要切换的窗口
]]
Class.Static(Window, "ToggleMaxsizeOrCenterPosition", function(wind)
    local savedFrame = Window._saved_window_frame;
    local windID = wind:id();
    local oldFrame = savedFrame[windID];
    if (oldFrame) then
        wind:move(oldFrame);
        savedFrame[windID] = nil;
    else
        if (windID) then
            savedFrame[windID] = wind:frame();
        end
        if (wind:isMaximizable()) then
            wind:maximize();
        else
            wind:centerOnScreen();
        end
        hs.mouse.setAbsolutePosition(wind:frame().center);
    end
end);
return Window;