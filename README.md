# Lua-Collections

A collection of basic lua data structures for Lua and LuaJIT

Working
- Array
- CArray (Requires LuaJIT)
- List

WIP
- Vector

**Documentation for each working module is in markdown format in docs/**

The documentation is directly generated from the source code, using DocumentationBuilder.java

This collections framework is built around composition, rather than inheritance. If you want an ArrayList, you do not import ArrayList and call `new` on it. Instead you create a new Array and then create a List around this array.

```lua
local array = require("Array")
local list = require("List")
local cArray = require("CArray") -- requires LuaJIT

local arrayList = list.new(array.new({1,2,4}))
arrayList:add(5):add(8)

local cArrayList = list.new(cArray.new("int", 1))
cArrayList:set(0, 1):add(2):add(4):add(5):add(8)

print(arrayList)  --> [1,2,4,5,8]
print(cArrayList) --> [1,2,4,5,8]
```

By composing a List from some table that handles the data less code is duplicated and you can define your own data representation to give to the already existing List, and get all of List's methods for free.

Note that while Array indexes start from 1, as Lua does, CArray indexes start from 0, as C arrays do. List will handle indexing for you when you are iterating over it. but you need to be careful if manually accessing indexes.

In Lua 5.1 List also monkeypatches the global ipairs method to correctly call `__ipairs` on a table as Lua 5.2+ do by default. If you've already done this you should comment out that section in List.
