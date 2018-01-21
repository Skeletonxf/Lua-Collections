local ffi = require "ffi"
 
local cArray = {
  _VERSION = "CArray 0.1",
  _DESCRIPTION =  [[Lua collections
    This class uses LuaJIT's FFI to use a C array
    inside a struct and thus will not run from pure lua
    This class is WIP and not ready for use yet

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

-- String reference, C Datatype -> Registers constructor for type
--   so can use cArray.new(stringReference)
--
-- adds a ctype type struct constructor to the list
-- of constructors
function cArray.newCType(luaStringReference, ctype)
  -- variable length (?) paramaterised type ($) array inside a struct
  -- with fields of current, max (lengths) and data
  local constructor = ffi.typeof([[
    struct { int current, max; $ data[?]; }
  ]], ctype)
  -- associate the struct with the metatable
  ffi.metatype(constructor, CArray)
  constructors[ctype] = constructor
  constructorReferences[luaStringReference] = ctype
end

-- default provided referenced types
-- external code can call this function to add other types if needed
cArray.newCType("int", ffi.typeof("int"))
cArray.newCType("double", ffi.typeof("double"))
cArray.newCType("float", ffi.typeof("float"))

-- String reference to C Datatype, Maximum length -> CArray
function cArray.new(datatype, length)
  if constructorReferences[datatype] then
    -- call this constructor with the length
    --
    -- first paramater to constructor is number of elements
    -- ie max size of array to create
    -- the current length field in the struct at creation 
    -- will be nothing*, and the max field will be track
    -- what the maximum length of this array is, so is
    -- the same value
    --
    -- *luajit will initialise the data to something
    -- depending on the type
    return constructors[constructorReferences[datatype]](length*2, length, length*2)
  else
    error("Invalid c datatype " .. datatype, 2, debug.traceback())
  end
end

-- CArray, Index -> Element at index
function CArray.access(struct, i)
  if i >= 0 and i <= struct:length() - 1 then
    return struct.data[i]
  else
    error("C Array index " .. tostring(i) .. "out of bounds",
      2, debug.traceback())
  end
end

-- TODO assign (needs to check datatype is valid)

-- CArray -> first element index
function CArray.start(struct)
  return 0
end

-- CArray -> current length of this array 
--   this is bounded by the maximum size of the array
function CArray.length(struct)
  return struct.current  
end

function CArray.setLength(struct, length)
  if length < struct.max and length >= 0 then
    struct.length = length
  else
    error("TODO Array needs resizing")
    -- Need to retrieve datatype of struct to resize
  end
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