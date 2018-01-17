local la = require "L-C.linear-algebra"

local foo = la.vector.new({1, 2, 3}):T()
local bar = la.vector.new({0, 2, 4})
print(foo)
print("*")
print(bar)
local baz = foo * bar
print("=")
print(baz)
print("^T=")
print(baz:T())