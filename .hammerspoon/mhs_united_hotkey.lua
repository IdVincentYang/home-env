--[[--* ref:
    - https://github.com/xiaket/etc/blob/master/hammerspoon/hiper.lua
    - https://github.com/hetima/hammerspoon-hyperex
]]
local Class = require("c3class");
local Exception = require("mhs_exception");
local InvalidArgument = Exception.InvalidArgument;

local _CLASS_NAME = "UnitedHotkey";

local _L = hs.logger.new(_CLASS_NAME, 5);

local UnitedHotkey = Class(_CLASS_NAME, {});

Class.Static(UnitedHotkey, "ActionMap", {});

--[[--
1. mods: t, key: s, message?: s, pressedFn?: f, releasedFn?: f, repeatedFn?: f, deferFn?: f
2. mods: t, key: s, obj: t, pressedFn?: f, releasedFn?: f, repeatedFn?: f, deferFn?: f
3. TODO: hotkey: s, message?: s, pressedFn?: f, releasedFn?: f, repeatedFn?: f, deferFn?: f
4. TODO: hotkey: s, obj: t, pressedFn?: f, releasedFn?: f, repeatedFn?: f, deferFn?: f
]]
Class.Static(UnitedHotkey, "Bind", function(...)
    if (select("#", ...) < 2) then
        return nil;
    end
    local mods, key, msgOrObj, pressedFn, releasedFn, repeatFn, deferFn;

    local arg1 = select(1, ...);
    local type1 = type(arg1);
    if (type1 == "table") then
        mods = arg1;
        key, msgOrObj, pressedFn, releasedFn, repeatFn = select(2, ...);
        if (msgOrObj == nil) then
            local hk = hs.hotkey.bind(mods, key, nil, pressedFn, releasedFn, repeatFn);
            if (hk and deferFn) then
                deferFn(hk);
            end
            return hk;
        elseif (type(msgOrObj) == "string") then
            local message = msgOrObj;
            if (pressedFn or releasedFn or repeatFn) then
                local hk = hs.hotkey.bind(mods, key, message, pressedFn, releasedFn, repeatFn);
                if (hk and deferFn) then
                    deferFn(hk);
                end
                return hk;
            else
                print(#UnitedHotkey.ActionMap);
                local action = UnitedHotkey.ActionMap[message];
                if (action) then
                    local message, pressedFn, releasedFn, repeatFn, deferFn = table.unpack(action);
                    local hk = hs.hotkey.bind(mods, key, message, pressedFn, releasedFn, repeatFn);
                    if (hk and deferFn) then
                        deferFn(hk);
                    end
                    return hk;
                else
                    _L.w("Invalid arguments for Bind: ", ...);
                    return nil;
                end
            end
        elseif (type(msgOrObj) == "table") then
            local hk = hs.hotkey.bind(
            mods,
            key,
            msgOrObj,
            pressedFn and function() pressedFn(msgOrObj) end or nil,
            releasedFn and function() releasedFn(msgOrObj) end or nil,
            repeatFn and function() repeatFn(msgOrObj) end or nil);
            if (hk and deferFn) then
                deferFn(hk);
            end
            return hk;
        else
            --  invalid arg3
            return nil;
        end
    else
        --  invalid arg1
        return nil;
    end
end);

Class.Static(UnitedHotkey, "BindSpecMap", function(specs)
    if (type(specs) ~= "table") then
        _L.e(InvalidArgument("BindSpecMap", specs));
        return;
    end
    UnitedHotkey.DeleteAll();
    for k, spec in pairs(specs) do
        if (type(spec) == "table" and #spec > 1) then
            UnitedHotkey.Bind(spec[1], k, table.unpack(spec, 2));
        end
    end
end);

Class.Static(UnitedHotkey, "DeleteAll", function()
    _L.d("TODO: DeleteAll");
end);

return UnitedHotkey;