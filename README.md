# Lua-Collections

A collecetion of basic lua data structures for Lua and LuaJIT

Provided
- ArrayList

WIP
- StructList (Using LuaJIT FFI)

## ArrayList methods/documentation/how do I use this/help plz

I recommend you just look at the ./L-C/arrayList.lua file as it is heavily commented and documented there on the source code. Regardless, you can also see it in use under profiling.lua and run a dummy profile of ArrayList vs ArrayList by running dummyProfile.lua.

### ArrayList methods

You can simply get all the methods provided by ArrayList by running some code like this:

```lua
local arrayList = require 'L-C.arrayList'

local ArrayListMT = arrayList.getClassMethods()

for name, functionValue in pairs(ArrayListMT) do
  print(name)
end
```

## Make/use an array list like this

```lua
local arrayList = require 'L-C.arrayList'
local myList = arrayList.new
local myListWithSomeValuesAlready = arrayList.new{1,2,4,5,6}
myList:addAll(myListWithSomeValuesAlready)
myList:remove()
```

Commented output of all ArrayList methods in a sensible order:

```
add(item) adds item to end of the list
delete() removes last entry of the list
pop() removes and returns the last enty of the list
dequeue() alias for pop
get(index) get item at this index, will return nil if out of bounds
insert(key, value) writes the key and value into the list if doing so will not create holes
set(key, value) alias for insert
insertPad(key, value) WIP version of insert that adds holes if has to
queue(item) inserts this item before the first in the list
contains(item) returns true if this item is in the list, false otherwise
addAll(table) adds all items of a table using ipairs() or another array list
clear() wipes all contents of the list
removeAll() alias for clear
isEmpty() returns true if the list is empty, false otherwise
__tostring() provides a string representation of the list for lua's print() function and others
toString() alias for __tostring
__eq() provides a function for lua's == token to check if two array lists are the same
forEach(consumer) calls the consumer function on each item in the list
forEachIndex(consumer) calls the consumer on each key in the list
forEachWithIndex(biconsumer) calls the biconsumer with each key, value pair
map(mappingFunction) returns a new list with each item as the result of this mapping function called with the value, key pairs in the original list
filter(predicate) returns a new list with all items kept by this predicate called with each item of the original list
asSet() returns a new list with no duplicate elements, the list could easily stop being a set afterwards
__index this actually isn't a method that does anything, it's just so Lua finds all the methods defined above when you try to call them
```

### I just want a stack or a queue

ArrayList aliases some methods to meaninful names for queues and stacks, there is a short example in monkeyPatchingTest.lua showing you how you can easily reduce down to a Stack (or Queue) by using ArrayList

### I just want a set

You could look at the example provided in monkeyPatchingTest.lua

### How does ArrayList work?

A metatable called ArrayList is defined with all the methods for the behaviour. When you call `require 'arrayList'` you get the wrapper table which has the new method. You can then pass arrayList's new method in a table or nil and you will get back either the table you passed in or a new table, with a metatable of the ArrayList. The ArrayList implementation is in that metatable and two new fields in your table called `__start` and `__length`, these are used to track the indexes the list uses. You can continue to access your table with all the traditional lua syntax like `myList[3]` and `#myList`, but you must manually update the `__start` and `__length` fields if you manually add or remove elements that change the indexes/structure of the list, the idea is you use the methods provided, after all. Additionally if you use `pairs(myList)` two of the results will be those `__start` and `__length` fields that you should not edit or delete without reason. As ArrayList supports nil values you could also create an ArrayList for which `#myList` gives you the wrong result, if you give it nil values.
