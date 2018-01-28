# List.lua

A List is composed of a representation table
which implements methods to access and retrieve data
from it. Therefore you can create Lists from
different underlying structures such as a plain Lua table
or LuaJit's C structs and reuse the same higher level code

This class defines what a List is, using any
representation type that supports the needed methods

This class also monkey patches Lua 5.1's ipairs global
method on file load to call `__ipairs` on tables that define it
as Lua 5.2+ behaves by default. Without this many iterative
methods in this file will break in Lua 5.1

## `function list.new(representation)`
RepresentationType -> List of that type

A valid representation type has the following
method signatures in its metatable

access :: Type, Index -> Value at index

assign :: Type, Index, Value -> assigns value to index

start :: Type -> starting index

length :: Type -> number of elements in type

setLength :: Type, new Length -> expands or shrinks the length

of the type, trivial for lua tables and not so trivial for structs

Construction only enforces that these functions exist
but they must be behave as so for the code to run properly

For example, to create an array list
`list.new(array.new({1,2,3}))`

## `function List.expand(list)`
List -> List one element longer

## `function List.shrink(list)`
List -> List one element shorter

## `function List.finish(list)`
List -> last element index

## `function List.isEmpty(list)`
List -> if list is empty

## `function List.indexInBounds(list, i)`
List, Index -> true if index is in the range of the list
ie between the start and end indexes of the list

## `function List.indexOutOfBounds(list, i)`
List, Index -> complement of indexInBounds

## `function List._iterator(list, i)`
iterator to traverse a List, handling nil values
because a List knows at what index it ends

## `function List.__ipairs(list)`
iterates over this list from start to finish
passing over nil values that are still in the list
this is different to how plain lua tables are
traversed as they do not know when they end
so that
`for k, v in ipairs(list) do
...
end`
just works even with holes in the data

## `function List._iteratorReverse(list, i)`
iterator to traverse a List backwards,
handling nil values because a List knows
at what index it starts

## `function List.iterateBackwards(list)`
iterates over this list from finish to start
passing over nil values that are still in the list

## `function List.add(list, value)`
List, Value -> List with value added to end

## `function List.get(list, index)`
List, Index -> Value at index
throws error on index out of bounds

## `function List.set(list, index, value)`
List, Index, Value -> List with value at index
throws error on index out of bounds

## `function List.pop(list)`
List -> List, Value at last index now removed
The value at last index is returned and 'removed' from datastructure
The element could still be present in memory but is no longer in the List bounds

## `function List.insert(list, index, value)`
List, Index, Value -> List with element inserted into index
shifts elements right by 1 to make room
throws error on index out of bounds

## `function List.remove(list, index)`
List, Index -> List, Value in list removed
shifts elements left by 1 to remove value at this index
throws error on index out of bounds

## `function List.contains(list, value)`
List, Value -> Boolean, Index
returns true and the index of the first occurance
of the element in this list if it is in the list
and returns false and nil otherwise

## `function List.delete(list, value)`
List, Value -> List, Value in list removed (if any)
removes first occurance (if any) of the value
does nothing to the List if the element does not exist

## `function List.clear(list)`
List -> empty List

## `function List.__eq(list1, list2)`
List, List -> Boolean
checks elementwise for every element pair
being equal in the two lists

## `function List.forEach(list, consumer)`
List, Consumer function -> List after function called
on every element in order

ie if the List has elements { 1, 2, 3 }
and the consumer function is
function(v, k) print(v) end
then list:forEach(consumer) prints
1
2
3

## `function List.map(list, mapping)`
then list:map(mapping) gives elements { 2, 4, 6 }

## `function List.addAll(list, values)`
List, table of Values -> List with Values added

takes a table of values such that iterating over them
with ipairs loops over each value in the table, returning
true if the List contains an occurance of every value
ie { "foo", "bar" } is valid
{ ["0"] = "baz" } is not (ipairs starts at 1)
{ ["foo"] = "bar" } is not

A List is also a valid table of values and so is
any table with a metatable that defines `__ipairs`
to correctly iterate over it

## `function List.containsAll(list, values)`
List, table of Values -> Boolean

takes a table of values such that iterating over them
with ipairs loops over each value in the table, returning
true if the List contains an occurance of every value
ie { "foo", "bar" } is valid
{ ["0"] = "baz" } is not (default ipairs starts at 1)
{ ["foo"] = "bar" } is not

A List is also a valid table of values and so is
any table with a metatable that defines `__ipairs`
to correctly iterate over it

If the List has values { 1, 0, 1 }
then containsAll(list, { 1, 1, 1}) will pass
because the first occurance of 1 in the list
will pass each value to check

## `function List.deleteAll(list, values)`
List, table of Values -> List with Values removed (if any)

takes a table of values such that iterating over them
with ipairs loops over each value in the table, returning
true if the List contains an occurance of every value
ie { "foo", "bar" } is valid
{ ["0"] = "baz" } is not (default ipairs starts at 1)
{ ["foo"] = "bar" } is not

A List is also a valid table of values and so is
any table with a metatable that defines `__ipairs`
to correctly iterate over it

If the List has values { 1, 1, 1 }
then list:deleteAll({ 1, 0, 1}) will remove the
first two elements only

## `function List.indexOf(list, value)`
List, Value -> Index of first occurance of value
in List if any, nil if not there

## `function List.retainAll(list, values)`
List, table of Values -> List with only elements equal
to the table of values

takes a table of values such that iterating over them
with ipairs loops over each value in the table, returning
true if the List contains an occurance of every value
ie { "foo", "bar" } is valid
{ ["0"] = "baz" } is not (default ipairs starts at 1)
{ ["foo"] = "bar" } is not

A List is also a valid table of values and so is
any table with a metatable that defines `__ipairs`
to correctly iterate over it

If the list has values { 1, 1, 0 } then
list:retainAll({0}) will remove every occurance of 0
this is different to the other All methods that
only remove first occurances because this method does
a full pass through the list to identify what to retain
before calling list:remove iterating backwards through
the entire list

## `function List.__tostring(list)`
List -> String representation


