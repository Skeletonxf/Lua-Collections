# Array.lua

Thin wrapper around a lua table providing
methods to manipulate numerical indices

This class is intended for use as the main data
representation of a List

Create an blank ArrayList:
local arrayList = list.new(array.new())
Create a pre initialised ArrayList:
local arrayList = list.new(array.new({1,2,3,4}))

## `function array.new(values)`
Values -> Array

## `function Array.access(array, i)`
Array, Index -> Element at index

## `function Array.assign(array, i, v)`
Array, Index, Value -> Assigns value to index

## `function Array.start(array)`
Array -> first element index

## `function Array.length(array)`
Array -> length of this array

## `function Array.setLength(array, length)`
Array, Length -> Assigns the length marker to
the new value for this array

## `function Array.copy(array)`
Array -> copy of Array, under a new table
copy will be shallow in some cases, elements which are tables
will be identical in both copy and original unless they
support this method as well
if all table elements support copy or there are none
then the copy will be deep


