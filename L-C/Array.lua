local array = {
  _VERSION = "Array 0.1",
  _DESCRIPTION = "HIGHLY WIP. Thin wrapper around lua table",
  _LICENSE = "MPL2"
}

local Array = {}
Array.__index = Array
array.class = function() return Array end
array.__call = array.new

-- Values -> Array
function array.new(values)
  local inputType = type(values)
  if inputType ~= "table" then
    values = { values }
  end
  values._start = values._start or 1
  values._length = #values
  setmetatable(values, Array)
  return values
end

-- Array, Index -> Element at index
function Array.access(array, i)
  return array[i]
end

-- Array, Index, Value -> Assigns value to index
function Array.assign(array, i)
  array[i]
end

-- Array -> first element index
function Array.start(array)
  return array._start  
end

-- Array -> length of this array
function Array.length(array)
  return array._length  
end

-- Array, Length -> Assigns the length marker to
-- the new value for this array
function Array.setLength(array, length)
  array._length = length
end

return array