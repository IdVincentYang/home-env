local Class = require("c3class");

local _CLASS_EXCEPTION_NAME = "Meteor.Exception";

local Exception = Class(_CLASS_EXCEPTION_NAME, {
    message = nil,
});

function Exception:toString()
    return self.message or _CLASS_EXCEPTION_NAME;
end

local _CLASS_INVALID_ARGUMENT_NAME = "InvalidArgument";

local InvalidArgument, super = Class(_CLASS_INVALID_ARGUMENT_NAME, Exception);

function InvalidArgument:ctor(funcName, arg)
    print(type(arg))
    self.message = string.format("%s. Function(%s)'s argument %s invalid.", _CLASS_INVALID_ARGUMENT_NAME, funcName, arg);
end

Class.Static(Exception, "InvalidArgument", InvalidArgument);
return Exception;