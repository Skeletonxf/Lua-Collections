local ffi = require "ffi"

-- this is a 'love2d' no window program to use LuaJIT's ffi for
-- testing struct list
local structList = require "L-C.structList"

-- create a double type struct of length 10
local doubleStructListTest = structList.new(ffi.typeof("double"), 10)

print(doubleStructListTest)
