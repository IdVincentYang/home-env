local Class = require("c3class");
local Application = require("mhs_application");
local UnitedHotkey = require("mhs_united_hotkey");

local Meteor = Class("Meteor", {});

Class.Static(Meteor, "Application", Application);
Class.Static(Meteor, "UnitedHotkey", UnitedHotkey);

return Meteor;