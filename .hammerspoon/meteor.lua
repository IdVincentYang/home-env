local Class = require("c3class");

local Meteor = Class("Meteor", {});

Class.Static(Meteor, "Application", require("mhs_application"));
Class.Static(Meteor, "UnitedHotkey", require("mhs_united_hotkey"));
Class.Static(Meteor, "Window", require("mhs_window"));

return Meteor;