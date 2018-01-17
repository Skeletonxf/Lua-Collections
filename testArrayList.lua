local arrayList = require "L-C.arrayList"

-- array list uses the same table it's given, so list is table
local list = arrayList.new{1,2,3}

local function printTableKeys()
  list:forEachWithIndex(function(k, v)
    print(tostring(k) .. ":" .. tostring(v))
  end)
end
print "Start"
printTableKeys()

list:add(4)
print "Added 4"
printTableKeys()

list:queue(0)
print "Queued 0"
printTableKeys()

list:pop()
print "Popped"
printTableKeys()

list:insert(-1,5)
print "Insert 5 at -1"
printTableKeys()

print "Test default __tostring for the list"
print(list)

local copy = arrayList.new{1,2,3}
copy:queue(0)
copy:queue(-5)
print(copy == list)
