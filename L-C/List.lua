local array = require "Array"

local list = {
  _VERSION = "List 0.1",
  _DESCRIPTION = [[
    HIGHLY WIP
    A List is composed of a representation table
    which implements methods to access and retrieve data
    from it. Therefore you can create Lists from
    different underlying structures such as a plain Lua table
    or LuaJit's C structs and reuse the same higher level code
  ]],
  _LICENSE = "MPL2"
}

local List = {}
List.__index = List
list.class = function() return List end
list.__call = list.new

-- RepresentationType -> List of that type
--
-- A valid representation type has the following
-- method signatures in its metatable
--
-- access :: Type, Index -> Value at index
-- assign :: Type, Index, Value -> assigns value to index
-- start :: Type -> starting index
-- length :: Type -> number of elements in type
-- setLength :: Type, new Length -> expands or shrinks the length
--   of the type, trivial for lua tables and not so trivial for structs
--
-- Construction only enforces that these functions exist
-- but they must be behave as so for the code to run properly
--
-- For example, to create an array list
-- ``list.new(array.new({1,2,3}))``
function list.new(representation)
  local providedMethods = {
    "access", "assign", "start", "length", "setLength", "copy"
  }
  local mt = getmetatable(representation)
  for k = #providedMethods, 1, -1 do
    local v = providedMethods[k]
    if mt[v] and type(mt[v]) == "function" then
      providedMethods[k] = nil
    end
  end
  if #providedMethods ~= 0 then
    error("Representaion type " .. tostring(representation)
      .. " does not implement all needed methods ", 2, debug.traceback())
  end
  local list = {
    data = representation
  }
  setmetatable(list, List)
  return list
end

-- Wrappers around the data type methods
-- that always return the list after
function List.access(list, i)
  return list.data:access(i)
end
function List.assign(list, i, v)
  list.data:assign(i, v)
  return list
end
function List.start(list)
  return list.data:start()
end
function List.length(list)
  return list.data:length()
end
function List.setLength(list, length)
  return list.data:setLength(length)  
end
function List.copy(list)
  return list.data:copy()
end

-- assertion function to throw error on out of bound indexes
local function assertIndexInBounds(list, i)
  if list:indexOutOfBounds() then
    error("List index " .. tostring(index) ..  " out of bounds",
      3, debug.traceback())
  end
end

-- assertion function to throw error on empty lists
-- for functions where list must be non empty
local function assertListNonEmpty(list)
  if list:isEmpty() then
    error("Empty list", 3, debug.traceback())
  end
end

-- List -> List one element longer
function List.expand(list)
  list:setLength(list:length() + 1)
  return list
end

-- List -> List one element shorter
function List.shrink(list)
  list:setLength(list:length() - 1)
  return list
end

-- List -> last element index
function List.finish(list)
  return list.data:start() + list.data:length() - 1
end

-- List -> if list is empty
function List.isEmpty(list)
  return list:length() == 0
end

-- List, Index -> true if index is in the range of the list
-- ie between the start and end indexes of the list
function List.indexInBounds(list, i)
  return (not list:isEmpty()) and i <= list:finish() and i >= list:start()
end

-- List, Index -> complement of indexInBounds
function List.indexOutOfBounds(list, i)
  return not list:indexInBounds(i)  
end

-- iterator to traverse a List, handling nil values
-- because a List knows at what index it ends
function List._iterator(list, i)
  i = i + 1
  if list:indexInBounds(i) then
    return i, list:access(i)
  end
  return nil
end

-- Lua 5.2+ only
-- iterates over this list from start to finish
-- passing over nil values that are still in the list
-- this is different to how plain lua tables are
-- traversed as they do not know when they end
-- so that
-- for k, v in ipairs(list) do
--   ...
-- end
-- just works even with holes in the data
function List.__ipairs(list)
  return List._iterator, list, list:start() - 1
end

-- alias
-- using list:iterate() will work in Lua 5.1
List.iterate = List.__ipairs

-- iterator to traverse a List backwards, 
-- handling nil values because a List knows 
-- at what index it starts
function List._iteratorReverse(list, i)
  i = i - 1
  if list:indexInBounds(i) then
    return i, List:access(i)
  end
  return nil
end

-- iterates over this list from finish to start
-- passing over nil values that are still in the list
function List.iterateBackwards(list)
  return List._iteratorReverse, list, list:finish() + 1
end

-- List, Value -> List with value added to end
function List.add(list, value)
  list:expand():assign(list:length(), value)
  return list
end

-- List, Index -> Value at index
-- throws error on index out of bounds
function List.get(list, index)
  assertIndexInBounds(list, index)
  return list:access(index)
end

-- List, Index, Value -> List with value at index
-- throws error on index out of bounds
function List.set(list, index, value)
  assertIndexInBounds(list, index)
  return list:assign(index, value)
end

-- List -> List, Value at last index now removed
-- The value at last index is returned and 'removed' from datastructure
-- The element could still be present in memory but is no longer in the List bounds
function List.pop(list)
  assertListNonEmpty(list)
  local v = list:access(list:finish())
  list:shrink()
  return list, v
end

-- List, Index, Value -> List with element inserted into index
-- shifts elements right by 1 to make room
-- throws error on index out of bounds
function List.insert(list, index, value)
  list:expand()
  assertIndexInBounds(list, index)
  -- shift subsequent elements of this index right by 1
  for i = list:finish() - 1, index, -1 do
    list.assign(i + 1, list:access(i))
  end
  list.assign(index, value)
  return list
end

-- List, Index -> List, Value in list removed
-- shifts elements left by 1 to remove value at this index
-- throws error on index out of bounds
function List.remove(list, index)
  assertIndexInBounds(list, index)
  local v= list:access(index)
  -- shift subsequent elements of this index left by 1
  for i = index, list:finish() - 1 do
    list.assign(i, list:access(i + 1))
  end
  list:shrink()
  return list, v
end

-- List, Value -> Boolean, Index
-- returns true and the index of the first occurance
-- of the element in this list if it is in the list
-- and returns false and nil otherwise
function List.contains(list, value)
  for k, v in ipairs(list) do
    if v == value then
      return true, k
    end
  end
  return false, nil
end

-- List, Value -> List, Value in list removed (if any)
-- removes first occurance (if any) of the value
-- does nothing to the List if the element does not exist
function List.delete(list, value)
  local has, k = list:contains(value)
  if has then
    local v = list:access(k)
    list:remove(k)
    return List, v
  end
  return List, nil
end

-- List -> empty List
function List.clear(list)
  list:setLength(0)
  return list
end

-- List, List -> Boolean
-- checks elementwise for every element pair
-- being equal in the two lists
function List.__eq(list1, list2)
  if list1:length() ~= list2:length() then
    return false  
  end
  for i = list1:start(), list1:finish() do
    if list1:access(i) ~= list2:access(i) then
      return false
    end
  end
  return true
end

-- alias
List.equals = List.__eq

-- List, Consumer function -> List after function called
--   on every element in order
--
-- ie if the List has elements { 1, 2, 3 }
-- and the consumer function is
-- function(v, k) print(v) end
-- then list:forEach(consumer) prints
-- 1
-- 2
-- 3
function List.forEach(list, consumer)
  for k, v in ipairs(list) do
    consumer(v, k)
  end
end

-- List, Mapping function -> List where every element is
--   mapped by the function
--
-- ie if the List has elements { 1, 2, 3 }
-- and the mapping function is
-- function(v, k) return 2*v end
-- then list:map(mapping) gives elements { 2, 4, 6 }
function List.map(list, mapping)
  for k, v in ipairs(list) do
    list:assign(k, mapping(v, k))
  end
end

-- List, table of Values -> List with Values added
--
-- takes a table of values such that iterating over them
-- with ipairs loops over each value in the table, returning
-- true if the List contains an occurance of every value
-- ie { "foo", "bar" } is valid
-- { ["0"] = "baz" } is not (ipairs starts at 1)
-- { ["foo"] = "bar" } is not
--
-- A List is also a valid table of values and so is
-- any table with a metatable that defines __ipairs
-- to correctly iterate over it
function List.addAll(list, values)
  for _, v in ipairs(values) do
    list:add(v)
  end
  return list
end

-- List, table of Values -> Boolean
--
-- takes a table of values such that iterating over them
-- with ipairs loops over each value in the table, returning
-- true if the List contains an occurance of every value
-- ie { "foo", "bar" } is valid
-- { ["0"] = "baz" } is not (ipairs starts at 1)
-- { ["foo"] = "bar" } is not
--
-- A List is also a valid table of values and so is
-- any table with a metatable that defines __ipairs
-- to correctly iterate over it
--
-- If the List has values { 1, 0, 1 }
-- then containsAll(list, { 1, 1, 1}) will pass
-- because the first occurance of 1 in the list
-- will pass each value to check
function List.containsAll(list, values)
  for _, v in ipairs(values) do
    if not list:contains(v) then
      return false
    end
  end
  return true
end

-- List, table of Values -> List with Values removed (if any)
--
-- takes a table of values such that iterating over them
-- with ipairs loops over each value in the table, returning
-- true if the List contains an occurance of every value
-- ie { "foo", "bar" } is valid
-- { ["0"] = "baz" } is not (ipairs starts at 1)
-- { ["foo"] = "bar" } is not
--
-- A List is also a valid table of values and so is
-- any table with a metatable that defines __ipairs
-- to correctly iterate over it
--
-- If the List has values { 1, 1, 1 }
-- then list:deleteAll({ 1, 0, 1}) will remove the
-- first two elements only
function List.deleteAll(list, values)
  for _, v in ipairs(values) do
    list:remove(v)
  end
  return list
end

-- List, Value -> Index of first occurance of value
--   in List if any, nil if not there
function List.indexOf(list, value)
  local has, k = list:contains(value)
  if has then
    return k
  end
  return nil
end

-- List, table of Values -> List with only elements equal
--   to the table of values
--
-- takes a table of values such that iterating over them
-- with ipairs loops over each value in the table, returning
-- true if the List contains an occurance of every value
-- ie { "foo", "bar" } is valid
-- { ["0"] = "baz" } is not (ipairs starts at 1)
-- { ["foo"] = "bar" } is not
--
-- A List is also a valid table of values and so is
-- any table with a metatable that defines __ipairs
-- to correctly iterate over it
--
-- If the list has values { 1, 1, 0 } then
-- list:retainAll({0}) will remove every occurance of 0
-- this is different to the other All methods that
-- only remove first occurances because this method does
-- a full pass through the list to identify what to retain
-- before calling list:remove iterating backwards through
-- the entire list
function List.retainAll(list, values)
  local deleteIndices = list.new(array.new())
  for k, v in ipairs(list) do
    if not List.contains(values, v) then
      -- this element needs to be removed
      deleteIndices:add(k)
    end
  end
  -- must iterate backwards so that indices
  -- remain correct as removing
  for _, index in deleteIndices:iterateBackwards() do
    list:remove(index)
  end
  return list
end

-- List -> String representation
function List.__tostring(list)
  if list:isEmpty() then
    return "[]"
  end
  local s = "["
  for k, v in ipairs(list) do
    s = s .. v .. ","
  end
  return s:sub(1, -2) .. "]"
end

-- FIXME swap all ipairs for Lua 5.1 compatible version
-- TODO implement subListing
-- replace arrayList with this
-- implement interface in Struct.lua for struct lists as started in structList.lua
-- will need to handle length changes in Struct.lua as Java's ArrayList does

return list
