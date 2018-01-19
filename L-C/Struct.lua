local ffi = require "ffi"
 
local struct = {
  _VERSION = "Struct 0.1",
  _DESCRIPTION =  [[Lua collections
    This class uses LuaJIT's FFI to back
    the representation by a C struct
    and thus will not run from pure lua
    This class is WIP and not ready for
    meaningful use yet
  ]],
  _LICENSE = "MPL2"
}

local Struct = {}
Struct.__index = Struct
struct.class = function() return Struct end
struct.__call = struct.new

-- Datatype, Length -> Struct
function struct.new(datatype, length)
  -- define a struct of a parameterised type of parametarised length
  -- and create it with this type
  -- FIXME Do not perform on every construction
  -- http://luajit.org/ext_ffi_api.html
  local struct = ffi.typeof([[
    struct {int start, length; $ data[?];}
  ]], datatype)
  -- give the struct the Struct metatable
  -- ffi.metatype returns a constructer to use for making structLists
  local new = ffi.metatype(struct, Struct)
  -- call this constructor with the length
  return new(length, 0, length)
end

-- Struct, Index -> Element at index
function Struct.access(struct, i)
  if i >= struct:start() and i <= struct:start() + struct:length() - 1 then
    return struct.data[i]
  end
end

-- Struct -> first element index
function Struct.start(struct)
  return struct.start
end

-- Struct -> length of this array
function Struct.length(struct)
  return struct.length  
end

-- Struct -> String representation
function Struct.__tostring(struct)
  local s = ""
  for i = struct:start(), struct:start() + struct:length() - 1 do
    s = s .. struct:access(i) .. ","
  end
  return s
end

return struct