local ffi = require "ffi"

local structList = {
  _VERSION = "Struct List 0.1",
  _DESCRIPTION = [[Lua collections
    This class uses LuaJIT's FFI to back
    the list by a C struct
    and thus will not run from pure lua
    This class is WIP and not ready for
    meaningful use yet
  ]]
}

-- create the metatable for implementing this class's methods
local StructList = {}
StructList.__index = StructList

function structList.new(datatype, length)
  -- define a struct of a parameterised type of parametarised length
  -- and create it with this type
  local struct_list = ffi.typeof([[
    struct {int start, length; $ data[?];}
  ]], datatype)
  -- give the struct the StructList metatable
  -- ffi.metatype returns a constructer to use for making structLists
  local new = ffi.metatype(struct_list, StructList)
  -- call this constructor with the length
  return new(length, 0, length)
end

function StructList:__tostring()
  local string = ""
  for i = self.start, self.start + self.length - 1 do
    string = string .. self.data[i] .. ","
  end
  return string
end

return structList
