local typeCheck = {
  _VERSION = "Type check 0.1",
  _DESCRIPTION = [[
    Utility for checking fields in tables (checking the type
    of tables you recieve).

    This is not as powerful as Intefaces in Java, but
    offers the same ability to enforce what type of
    arguments your code takes, to a lesser extent and only
    at runtime.

example

local typeCheck = require 'type-check'

local value = {
  0, 1, 3, 5, 9,
  foo = {
    'bar',
    baz = {
      foobar = {}
    },
    'foobarbaz'
  }
}

print(
  typeCheck.check(value):has(0)
    :at('foo'):has('bar')
      :at('baz'):at('foobar'):back()
    :at('foo'):has('foobarbaz')
  :collect()
)

$ lua example.lua
true
  ]],
  _LICENSE = "MPL2",
  _AUTHOR = "Skeletonxf",
  _URL = "https://github.com/Skeletonxf/Lua-Collections"
}

local TypeChecker = {}
TypeChecker.__index = TypeChecker

function typeCheck.check(value)
  local o = {
    value = value,
    head = value,
    passed = true,
  }
  setmetatable(o, TypeChecker)
  return o
end

-- dummy function for matching function existence
function typeCheck.f() end

-- checks if the value is at this index at 
-- the position of the head
function TypeChecker:hasAt(value, index)
  if not self.passed then
    return self
  end 
  if self.head[index] == value then
    -- still passing
    return self
  end
  if value == typeCheck.f then
    if type(self.head[index]) == "function" then
      -- still passing
      return self
    end
  end
  -- failed check
  self.passed = false
  return self
end

-- checks if the value is at any numerical index
-- at the position of the head
function TypeChecker:has(value)
  if not self.passed then
    return self
  end
  local passed = false
  for k, _ in ipairs(self.head) do
    if not passed then
      passed = (self.head[k] == value) or 
          (type(self.head[k]) == "function" and value == typeCheck.f)
    end
  end
  self.passed = passed
  return self
end

-- moves the head into the key, or fails if the key
-- doesn't exist
function TypeChecker:at(key)
  if not self.passed then
    return self
  end
  if self.head[key] then
    self.head = self.head[key]
  else
    self.passed = false
  end
  return self
end
-- alias
TypeChecker.down = TypeChecker.at

-- moves the head back to the root of the value to check
function TypeChecker:root()
  if not self.passed then
    return self
  end
  self.head = self.value
  return self
end
-- alias
TypeChecker.back = TypeChecker.root

-- collects the check result and returns it
-- true if all checks passed, false if any failed
function TypeChecker:collect()
  return self.passed
end
-- aliases
TypeChecker.get = TypeChecker.collect
TypeChecker.stop = TypeChecker.collect

return typeCheck
