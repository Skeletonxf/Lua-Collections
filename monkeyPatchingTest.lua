--[[
While this library is inspired by the JCF, it is
implemented in a lua like way, rather than managing
inheritance trees and classes you can take advantage
of over-writing methods with monkeypatching
If you want an ordered set, you could override the add,
insert and queue methods of arrayList like so, though this isn't
complete, as you would also have other methods to override
to fully enforce the uniqueness such as map()
 ]]--
    local arrayList = require 'L-C.arrayList'
    -- changing these functions would change all list behaviour
    local addMethod = arrayList.getClassMethods().add
    local insertMethod = arrayList.getClassMethods().insert
    local queueMethod = arrayList.getClassMethods().queue
    -- to just affect this table's behaviour you can apply the functions onto
    -- the table itself, instead of the metatable
    local set = arrayList.new{1,2,3,4,5}
    local list = arrayList.new{1,2,3,4,5}
    function set:add(value)
      if set:contains(value) then
        -- don't add
      else  
        addMethod(set,value)
      end
    end
    function set:insert(key, value)
      if set:contains(value) then
        -- don't add
      else  
        insertMethod(set,value,key)
      end
    end
    function set:queue(value)
      if set:contains(value) then
        -- don't add
      else
        queueMethod(set,value)
      end
    end
print 'Before any changes'
print 'Set'
set:forEach(print)
print 'List'
list:forEach(print)
set:insert(2,3)
list:insert(2,3)
print 'Now 3 inserted at 2'
print 'Set'
set:forEach(print)
print 'List'
list:forEach(print)
set:add(3)
list:add(3)
print 'Now 3 added'
print 'Set'
set:forEach(print)
print 'List'
list:forEach(print)
set:queue(4)
list:queue(4)
print 'Now 4 queued'
print 'Set'
set:forEach(print)
print 'List'
list:forEach(print)
set:queue(0)
list:queue(0)
print 'Now 0 queued'
print 'Set'
set:forEach(print)
print 'List'
list:forEach(print)
--[[ final output is
Set
0
1
2
3
4
5
List
0
4
1
3
3
4
5
3
]]--
--[[
But I want more than one set!
Then you should apply these overrides as part of a metatable
for all your sets, and piggyback on the rest of the methods
of ArrayList
  -- your overriding methods for set behaviour
  local setMethods = {}
  function setMethods:add(value)
    .... as before but applying these to the table
  end
  -- give this table the array list metatable
  -- lua will find your overrides first due to the lookup
  -- and fall back on these for the rest of the time
  setmetatable(setMethods, arrayList.getClassMethods())
  -- you might want to make this a module in its own file 
  -- or something but this is the general idea
  function newSet(args)
    -- get back an array list
    local set = arrayList.new(args)
    -- override the metatable with our one
    setmetatable(set, setMethods)
    return set
  end
  local set1 = newSet{1,2,3,4,5}
  local set2 = newSet{"s","e","t"}
  local set3 = newSet()
  local set4 = newSet(-4)
]]--
