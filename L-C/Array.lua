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
function Array.assign(array, i, v)
  array[i] = v
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

-- Array -> copy of Array, under a new table
-- copy will be shallow in some cases, elements which are tables
-- will be identical in both copy and original unless they
-- support this method as well
-- if all table elements support copy or there are none
-- then the copy will be deep
function Array.copy(array)
  -- tables are pass by reference
  -- must create a new table to perform a deep copy
  local copy = array.new()
  for k = array:start(), array:start() + array:length() - 1 do
    local v = array:access(k)
    if type(v) == "table" and v.copy then
        -- call copy recursively if it exists to ensure
        -- copy is not shallow
        v = v:copy()
    end
    copy:assign(k, v)
  end
  return copy
end

return array