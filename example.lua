-- this is a very short and basic Lua code snippit
-- showing 'object orientation' in Lua using
-- a table to hold the methods common to all instances
-- of a 'class', with 'instances' being unique tables
-- that have the methods as a metatable
-- and also the 'static/class methods' held in the wrapper
-- table are not inherited and are called
-- without the use of a : because they have no state
local methods = {}

-- lua will now look at `methods` when looking for
-- a field in a table that has methods as a metatable
methods.__index = methods

--[[ to be clearer for understanding this could have been
methods.__index = {
  sayHi = function(self)
    print("hello" .. tostring(self))
  end
}
but this becomes unwieldy with loads of methods
]]--

-- using : instead of . means there is an implicit `self`
-- variable passed as the first argument to this function
-- which will be the object/table that is invoking
-- this method
function methods:sayHi()
	print("hello" .. tostring(self))
end

local class = {}

function class.new()
	local object = {} -- tables are objects
	setmetatable(object, methods)
	return object
end

print "create an object using a 'class constructor'"
print "class.new()"
print(class.new())
print "call a 'method' on it"
print "class.new():sayHi()"
print(class.new():sayHi())
print "store an object"
print "x = class.new()"
x = class.new()
print(x)
print "call a method on it"
print "x:sayHi()"
print(x:sayHi())
print "call a method with ."
print "x.sayHi(x)"
print(x.sayHi(x))
print "you see this is the same result"

return class -- for using outside this file

