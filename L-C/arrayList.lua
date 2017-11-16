-- define the wrapper
local arrayList = {
  _VERSION = "Array List 0.1",
  _DESCRIPTION = [[Lua collections
    This implementation of an Array List is
    extremely lightweight, and is essentially a
    metatable for a standard lua table
    This class provides common behaviour for
    array lists, queues and stacks, inspired
    mainly from the Java Collections Framework
    This class tracks the length and starting 
    point of the array internally, if you
    want to manually remove or add items
    you must update __length and __start
    accordingly or you will break this class's methods
    Reading and even setting existing values is safe
    as long as the structure of the list is not changed
    Because this list tracks its start and end points,
    using # for length may be wrong, and the list can
    support nil values
    
    _FAIL_FAST value: 
    When true some behaviour will throw errors instead of trying
    to gracefully carry on. When this is false you may encounter
    silent errors, when true you need to be able to catch the
    errors to avoid crashing the program. To catch errors rather
    than ignore them the code will also have to perform additional
    checks in some functions which will decrease efficiency.
  ]],
  _FAIL_FAST = false
}

-- define the ArrayList metamethods
-- this is essentially what makes the 'class'
-- a common set of functions for each table using
-- this table as a metatable
local ArrayList = {}
-- make lua find the methods when looking at this metatable
ArrayList.__index = ArrayList

-- Returns the meta table used for providing all methods of a list.
-- modifying or adding to these methods will affect the behaviour
-- of all lists backed by this meta table, so know what you're doing
-- if you use this
arrayList.class = function() return ArrayList end
-- alias to support older code
arrayList.getClassMethods = arrayList.class

-- lets you simply use 'arrayList' to create a new arrayList instead
arrayList.__call = arrayList.new

-- create a new array list, taking nothing, a string, number or table
-- returns the/a table backed by the ArrayList metatable
-- if a table is provided it needs to have no holes and start
-- at one, or you need to manually set .__start and .__length appropriately
-- after calling this method, or FAIL_FAST behaviour will throw an error
function arrayList.new(list)
    -- make the table if not provided
    local list = list or {}
    local typeGiven = type(list)
    if typeGiven ~= "table" then
        if (type(list) == "number") or (type(list) == "string") then
            -- create a list with the first value as this
            list = {list}
        else
            error("Attempt to create new array list from unsupported type", 
                2, debug.traceback())
        end
    end
    -- give the list the metatable of ArrayList
    setmetatable(list, ArrayList)
    -- update length variable
    if arrayList._FAIL_FAST then
        if not list.__length then
            if typeGiven == "table" then
                for k, v in pairs(list) do
                    -- check for indexes below 1 or
                    -- holes in provided list
                    if k < 1 then
                        error("Indexes below 1 in supplied list" ..
                            "please provide .__length field" ..
                            "in supplied lists with indexes below 1",
                            2, debug.traceback())
                    end
                    if (v == nil) and (k[v+1] ~= nil) then
                        error("Hole present in supplied list" ..
                            "please provide .__length field" ..
                            "in supplied lists with holes",
                            2, debug.traceback())
                    end
                end
            end
        end
    end
    -- set list length by provided or length of list
    list.__length = list.__length or #list
    list.__start=1
    return list
end

-- self is implicitly the first value passed to
-- these functions due to the use of : instead of 
-- the normal . for calling the method
function ArrayList:add(value)
    self.__length = self.__length + 1
    self[self.__length] = value
end

-- may return null
-- completely analagous to calling table[index]
-- on the list table itself
-- FAIL_FAST will throw error in trying to get index outside
-- list length
function ArrayList:get(index)
    if arrayList._FAIL_FAST then
        if index > self.__start + self.__length - 1 then
            error("Attempt to get index " .. index ..
                " of greater value than list length" ..
                (self.__start + self.__length - 1),
                2, debug.traceback())
        end
    end
    return self[index]
end

-- removes last entry of the list
function ArrayList:delete()
    if self.__length > 0 then
        self[__start+self.__length-1] = nil
        self.__length = self.__length - 1
    else
        if arrayList._FAIL_FAST then
            error("Attempt to delete last entry of empty list",
                2, debug.traceback())
        end
    end
end

-- returns last value of the list and removes it 
function ArrayList:pop()
    local k = self.__start+self.__length-1
	local v = self[l]
	self[k] = nil
    self.__length = self.__length - 1
	return v
end

-- alias
ArrayList.dequeue = ArrayList.pop

-- rather than shunting all other values up, puts this value
-- at a lower index, possibly in negatives, and decrements
-- the track of where this array starts
function ArrayList:queue(value)
    self.__start = self.__start - 1
	self[self.__start] = value
    self.__length = self.__length + 1
end

-- wipes the array list
function ArrayList:clear()
    self = { __start = 1, __length = 0 }
end

-- alias
ArrayList.removeAll = ArrayList.clear

function ArrayList:isEmpty()
    return self.__length == 0
end

-- If this list already has an element with this index,
-- or the index is at the end of this list's range, meaning
-- it can be added without creating any holes, then inserts 
-- an element into this index in the list, overriding
-- any value that was there before
function ArrayList:insert(key, value)
    -- if the key is inside this list's range already
    if (key >= self.__start) and (key <= self.__start + self.__length - 1) then
       -- override
       self[key] = value
       return
    end
    if key == (self.__start - 1) then
       self.__start = self.__start - 1
       self.__length = self.__length + 1
       -- queue at start
       self[key] = value
       return
    end
    if key == self.__length + 1 then
       self.__length = self.__length + 1
        -- append to end
       self[key] = value
       return
    end
    if arrayList._FAIL_FAST then
        error("Failed to insert into list",
            2, debug.traceback())
    end
end

-- alias
ArrayList.set = ArrayList.insert

-- performs a more liberal insertion, padding the list with
-- nils to reach this position if it was not already within
-- the list's range, and will always insert the element
-- to the given position
-- TODO untested
function ArrayList:insertPad(key, value)
    self[key] = value
    if key < self.__start then
        self.__length = self.__length + (self.__start - key)
        self.__start = key
        return
    end
    if key > (self.__start + self.__length - 1) then
        self.__length = self.__length + (key - self.__length)
    end
end

-- adds all elements of the table or array list to this
-- array list, using the list's start and length if it exists
-- and if not replying on ipairs() to loop through all the elements
function ArrayList:addAll(table)
    if table.__start and table.__length then
        for k = table.__start, table.__start + table.__length - 1 do
            self:add(table[k])
        end
    else
        for k, v in ipairs(table) do
            self:add(v)
        end
    end
end

-- applies this function to each element of this list
-- and returns the result as a new list without
-- mutating this list
-- if you want mutation you should use some form of forEach
-- with an appropriate function
function ArrayList:map(mappingFunction)
    local mappedTable = {}
    for k, v in pairs(self) do
        if k ~= "__start" and k ~= "__length" then
        	mappedTable[k] = mappingFunction(v, k)
	end
    end
    return arrayList.new(mappedTable)
end

-- returns true if the element is equal to an
-- element in this list, false if not
function ArrayList:contains(element)
    for k = self.__start, self.__start + self.__length - 1 do
        if self[k] == element then
            return true
        end
    end
    return false
end

--[[ calls a function that consumes the value of each element in this list
   for example:
   local arrayList = require 'arrayList'
   someList = arrayList.new{1,2,3,4,5}
   -- pass the print function provided by lua
   someList:forEach(print)
   --> 1,2,3,4,5
--]]
function ArrayList:forEach(consumerFunction)
    for k = self.__start, self.__start + self.__length - 1 do
        consumerFunction(self[k])
    end
end

-- calls a function that consumes the value of each index that holds
-- a value in this list
function ArrayList:forEachIndex(consumerFunction)
    for k = self.__start, self.__start + self.__length - 1 do
        consumerFunction(k)
    end
end

-- passes the BiConsumer function every key and value pair
-- of the list's elements
function ArrayList:forEachWithIndex(biConsumerFunction)
    for k = self.__start, self.__start + self.__length - 1 do
        biConsumerFunction(k, self[k])
    end
end

-- returns a new 1 indexed array list with no holes
-- containing all items kept by this predicate from this
-- array list, this array list is unchanged
function ArrayList:filter(predicate)
    local filteredTable = {}
    local filteredTableLength = 0
    for k = self.__start, self.__start + self.__length - 1 do
        if predicate(self[k]) then
            filteredTableLength = filteredTableLength + 1
            filteredTable[filteredTableLength] = self[k]
	end
    end
    return arrayList.new(filteredTable)
end

-- loops through this list and creates a list with 
-- only the unique elements of this list, in their original
-- order. This list is unchanged
function ArrayList:asSet()
    local set = {}
    local setLength = 0
    local setContains = {}
    for k = self.__start, self.__start + self.__length - 1 do
        if (not setContains[self[k]]) then
            setContains[self[k]] = true
            setLength = setLength + 1
            set[setLength] = self[k]
        end
    end
    return arrayList.new(set)
end

-- defines the __tostring function lua will call in methods like print()
-- for huge lists this may be very slow
function ArrayList:__tostring()
    local string = "List["
    self:forEachWithIndex(function(k, v)
        string = string .. "[" .. k .. "," .. v .. "]"
    end)
    return string .. "]"
end

-- aliases, you should rarely need to directly call this method though
ArrayList.toString = ArrayList.__tostring

-- defines the equality function lua calls when using == between two
-- tables that both have this metatable, ie two array lists
function ArrayList:__eq(list)
    if list.__start then
        if list.__length then
            if list.__start == self.__start then
                if list.__length == self.__length then
                    self:forEachWithIndex(function(k, v)
                        if v ~= list[k] then
                            -- an element is not the same
                            return false
                        end
                    end)
                    -- every element is the same
                    return true
                end
            end
        end
    end
    return false
end

-- TODO
--[[
max(),min(),sorting,replace/retain/removeAll/containsAll/sub listing/ decide what to do with # override,
less and greater than, add/sub/mul/div/mod/pow/-/ some way to make pairs() ignore __start and __length, 
shifting to 0/1 index
]]--

-- return the wrapper for use in other files
return arrayList

