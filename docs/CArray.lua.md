# CArray.lua

This class uses LuaJIT's FFI to use a C array
inside a struct and thus will not run from pure lua
This class is WIP but can be used to create a List
by the following
local list = list.new(cArray.new("int", 3))

Note that CArrays have a type and a length. The length is
dynamically updated whenever required, but luajit will
throw errors if you try to assign the wrong types

A quote from luajit.org
"The FFI library has been designed as a low-level library.
The goal is to interface with C code and C data types
with a minimum of overhead. This means you can do anything you
can do from C: access all memory, overwrite anything in memory,
call machine code at any memory address and so on.

The FFI library provides no memory safety, unlike regular Lua code.
It will happily allow you to dereference a NULL pointer,
to access arrays out of bounds or to misdeclare C functions.
If you make a mistake, your application might crash,
just like equivalent C code would."

Hence it is strongly advised to use this class
only by its own methods - and be careful even then.

## `function cArray.newCType(stringTypeRef, ctype)`
String type reference, C Datatype -> Registers constructor for type
so can use cArray.new(stringReference)

Adds a ctype type struct constructor to the list
of constructors

## `function cArray.new(typeRef, length)`
String reference to C Datatype, Length -> CArray

By default "int", "double", and "float" are already registered
as types to create CArrays from. You can register
new types by using cArray.newCType()

## `function CArray.access(struct, i)`
CArray, Index -> Element at index

## `function CArray.assign(struct, i, v)`
CArray, Index, Value -> Assigns value to index

## `function CArray.start(struct)`
CArray -> first element index

## `function CArray.length(struct)`
CArray -> current length of this array
this is bounded by the maximum size of the array

## `function CArray.setLength(struct, length)`
CArray, Length -> CArray of this length

Old CArray is assumed to be ready for gc if resized

If you want to keep the old length CArray you must copy
first

## `function CArray.copy(struct)`
CArray -> copy of this CArray

## `function CArray.__tostring(struct)`
CArray -> String representation


