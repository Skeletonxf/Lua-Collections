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
-- access :: Type, Index -> Element at index
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
    "access", "assign", "start", "length", "setLength"
  }
  for k, v in pairs(getmetatable(representation)) do
    if providedMethods[k] and type(v) == "function" then
      providedMethods[k] = nil
    end
  end
  if #providedMethods == 0 then
    error("Representaion type " .. tostring(representation)
      .. " does not implement needed methods ", 2, debug.traceback())
  end
  local list = {
    data = representation
  }
  setmetatable(list)
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

-- assertion function to throw error on out of bound indexes
local function assertIndexInBounds(list, i)
  if list:indexOutOfBounds() then
    error("List index " .. tostring(index) ..  " out of bounds"
      , 3, debug.traceback())
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
function list.finish(list)
  return list.data:start() + list.data:length() - 1
end

-- List -> if list is empty
function List.isEmpty(list)
  return list:length() > 0
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
    return i, List:access(i)
  end
  return nil
end

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

-- List, Value -> List with value added to end
function List.add(list, value)
  list:expand():assign(list:length(), value)
  return list
end

-- List, Index -> Element at index
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

-- List -> List, Element at last index now removed
-- The element at last index is returned and 'removed' from datastructure
-- The element could still be present in memory but is no longer in the List bounds
function List.pop(list)
  assertListNonEmpty(list)
  local v = list:access(list:finish())
  list:shrink()
  return list, v
end

-- List, Index, Element -> List with element inserted into index
-- shifts elements right by 1 to make room
-- throws error on index out of bounds
function List.insert(list, index, element)
  list:expand()
  assertIndexInBounds(list, index)
  -- shift subsequent elements of this index right by 1
  for i = list:finish() - 1, index, -1 do
    list.assign(i + 1, list:access(i))
  end
  list.assign(index, element)
  return list
end

-- List, Index -> List, Value in list removed
-- shifts elements left by 1 to remove value at this index
-- throws error on index out of bounds
function List.remove(list, index)
  assertIndexInBounds(list, index)
  local value = list:access(index)
  -- shift subsequent elements of this index left by 1
  for i = index, list:finish() - 1 do
    list.assign(i, list:access(i + 1))
  end
  list:shrink()
  return list, value
end

-- TODO implement contains, clear, equals, addAll, removeAll, mapping functions, toString
-- replace arrayList with this
-- implement interface in Struct.lua for struct lists as started in structList.lua

return list
