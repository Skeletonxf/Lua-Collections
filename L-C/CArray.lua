local ffi = require "ffi"

local cArray = {
  _VERSION = "CArray 0.1",
  _DESCRIPTION =  [[
    This class uses LuaJIT's FFI to use a C array
    inside a struct and thus will not run from pure lua
    This class is WIP but can be used to create a List
    by the following
    local list = list.new(cArray.new("int", 3))

    Note that CArrays have a type and a length. The length is
    dynamically updated whenever required, but luajit will
    throw errors if you try to assign the wrong types

    A quote from luajit.org
    "The FFI library has been designed as a low-level library.
    The goal is to interface with C code and C data types
    with a minimum of overhead. This means you can do anything you
    can do from C: access all memory, overwrite anything in memory,
    call machine code at any memory address and so on.

    The FFI library provides no memory safety, unlike regular Lua code.
    It will happily allow you to dereference a NULL pointer,
    to access arrays out of bounds or to misdeclare C functions.
    If you make a mistake, your application might crash,
    just like equivalent C code would."
    
    Hence it is strongly advised to use this class 
    only by its own methods - and be careful even then.
  ]],
  _LICENSE = "MPL2"
}

local CArray = {}
CArray.__index = CArray
-- Note, this metatable associated with each constructor
-- is permenent and unchangable
-- this should be treated as read only
cArray.class = function() return cArray end
cArray.__call = cArray.new

-- table of lua strings referencing constructors 
local constructorReferences = {}
-- table with keys to constructors of the keyed type struct
local constructors = {}

-- String type reference, C Datatype -> Registers constructor for type
--   so can use cArray.new(stringReference)
--
-- adds a ctype type struct constructor to the list
-- of constructors
function cArray.newCType(stringTypeRef, ctype)
  -- variable length (?) paramaterised type ($) array inside a struct
  -- with fields of current, max (lengths) and data
  local constructor = ffi.typeof([[
    struct {
      int current;
      int max;
      $ data[?];
    }
  ]], ctype)
  -- associate the struct with the metatable
  ffi.metatype(constructor, CArray)
  constructors[ctype] = constructor
  constructorReferences[stringTypeRef] = ctype
end

-- default provided referenced types
-- external code can call this function to add other types if needed
cArray.newCType("int", ffi.typeof("int"))
cArray.newCType("double", ffi.typeof("double"))
cArray.newCType("float", ffi.typeof("float"))

-- Ctype, String reference to C Datatype, Length -> CArray
-- use cArray.new for creating CArrays outside this file
local function new(ctype, typeRef, length)
  -- call this constructor with the length
  --
  -- first paramater to constructor is variable number of elements
  -- ie size of array to create
  -- the current length field in the struct at creation 
  -- will also be this, and the max field will be track
  -- what the maximum length of this array is, so is also
  -- the same value
  -- the next field is the string that references the constructor
  --
  -- *luajit will initialise the data to something
  -- depending on the type
  local struct = constructors[ctype](length, length, length)
  -- hold reference to the string needed to fetch the
  -- constructor to create this type of struct as a value
  -- in the metatable indexed by this struct
  -- (cannot add fields to the struct as it is not a table)
  CArray[struct] = typeRef
  return struct
end

-- String reference to C Datatype, Length -> CArray
function cArray.new(typeRef, length)
  -- check the ctype for this string reference exists
  if constructorReferences[typeRef] then
    return new(constructorReferences[typeRef], typeRef, length)
  else
    error("Invalid c datatype '" .. typeRef ..
      "'\nregister new types with cArray.newCType",
      2, debug.traceback())
  end
end

-- CArray, Index -> Element at index
function CArray.access(struct, i)
  if i >= 0 and i < struct:length() then
    return struct.data[i]
  else
    error("C Array index " .. tostring(i) .. "out of bounds",
      2, debug.traceback())
  end
end

-- CArray, Index, Value -> Assigns value to index
function CArray.assign(struct, i, v)
  if i >= 0 and i < struct:length() then
    struct.data[i] = v
  else
    error("C Array index " .. tostring(i) .. "out of bounds",
      2, debug.traceback())
  end
end

-- CArray -> first element index
function CArray.start(struct)
  return 0
end

-- CArray -> current length of this array 
--   this is bounded by the maximum size of the array
function CArray.length(struct)
  return struct.current  
end

-- CArray, Length -> CArray of this length
function CArray.setLength(struct, length)
  if length < struct.max and length >= 0 then
    struct.current = length
  else
    -- resize by creating new larger array
    local newStruct = cArray.new(CArray[struct], struct.max*2)
    for i = 0, struct:length() - 1 do
      newStruct:assign(i, struct:access(i))
    end
    newStruct.current = length
    -- delete reference to this struct's string reference to
    -- its type in the metatable so it can be garbage collected
    CArray[struct] = nil
    -- overwrite the old struct with the new one
    struct = newStruct
  end
  return struct
end

function CArray.copy(struct)
  local newStruct = cArray.new(CArray[struct], struct.max)
  for i = 0, struct:length() - 1 do
    newStruct:assign(i, struct:access(i))
  end
  newStruct.current = struct.current
  return newStruct
end

-- CArray -> String representation
function CArray.__tostring(struct)
  local s = "["
  for i = 0, struct:length() - 1 do
    s = s .. tostring(struct:access(i)) .. ","
  end
  return s:sub(1, -2) .. "]"
end

return cArray