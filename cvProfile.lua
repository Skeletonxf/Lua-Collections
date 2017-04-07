local profiler = require 'LuaCollections.profiling'

local arrayList = require 'LuaCollections.L-C.arrayList'

--[[
This is a example file for profiling Lua-Collection's arrayList against
ClockVapors's collections' arrayList which is here: https://github.com/ClockVapor/collections
To run this file I put this file outside the LuaCollections repository
and added ./ClockVaporCollections/src/array_list along with all the other
files
]]--

package.path = package.path .. ';ClockVaporCollections/src/?.lua'
require 'ClockVaporCollections.src.array_list'

-- ClockVapor collections creates globals instead
local cvList1 = ArrayList()
local cvList2 = ArrayList()

-- as ClockVapor's collections framework uses different method names alias them here
-- this should have 0 impact on performance the way this is done
-- and in comparison to prior manual editing of the method called in profiling
-- impact is negligible if any
local cvListMT = getmetatable(cvList1)
cvListMT.__class.__parent.__base.forEach = cvListMT.__class.__parent.__base.foreach
cvListMT.__class.__parent.__base.forEach = cvListMT.__class.__parent.__base.foreach
cvListMT.__class.__parent.__base.addAll = cvListMT.__class.__parent.__base.add_all
cvListMT.__class.__base.asSet = cvListMT.__class.__base.unique

-- runs the profiler using Lua-Collection's array list against ClockVapor's
profiler.run(arrayList.new(), arrayList.new(), cvList1, cvList2, "L-C", "CVC")

--[[
As you can see Lua-Collections usually outperforms ClockVapor's collections
by a significant amount, except in using contains()
This is likely because ClockVapor's implementation has a cache of its item's
indicies so the call runs in constant time, where as Lua-Collection's array
list is more lightweight and does not have any such cache, so must perform
lookups equal to the length of the array, which is very large under the profiler
Output on my machine:
No library's accessing time is 0.0730430
CVC's accessing time is 3.7270160
L-C's accessing time is 0.2943580
L-C's time is 12.6615 times faster than CVC's
Pure lua's time is 4.0299 times faster than L-C
No library's mapping time is 0.1696870
CVC's mapping time is 3.7270160
L-C's mapping time is 0.5527220
L-C's time is 6.7430 times faster than CVC's
Pure lua's time is 3.2573 times faster than L-C
No library's forEaching time is 0.0799090
CVC's forEaching time is 0.0778020
L-C's forEaching time is 0.0421570
L-C's time is 1.8455 times faster than CVC's
L-C's time is 1.8955 times faster than pure lua
No library's non existent contains check time is 0.0556060
CVC's non existent contains check time is 0.0000040
L-C's non existent contains check time is 0.0210470
CVC's time is 5261.7500 times faster than L-C's
CVC's time is 13901.5000 times faster than pure lua
No library's filtering time is 0.2948540
CVC's filtering time is 1.9409960
L-C's filtering time is 0.0848610
L-C's time is 22.8727 times faster than CVC's
L-C's time is 3.4746 times faster than pure lua
No library's add all time is 0.2815390
CVC's add all time is 2.2707760
L-C's add all time is 0.1041910
L-C's time is 21.7944 times faster than CVC's
L-C's time is 2.7021 times faster than pure lua
No library's get list of unique elements time is 1.5171280
CVC's get list of unique elements time is 4.9435660
L-C's get list of unique elements time is 0.6039300
L-C's time is 8.1857 times faster than CVC's
L-C's time is 2.5121 times faster than pure lua
]]--
