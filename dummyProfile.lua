local profiler = require 'profiling'

local arrayList = require 'L-C.arrayList'

-- runs the profiler using Lua-Collection's array list against itself
profiler.run(arrayList.new(), arrayList.new(), arrayList.new(), arrayList.new(), "L-C", "L-C2")

--[[
As you can see L-C generally outperforms simple pure lua implementations
as pure lua calls the # operator which has to loop through the array each time
Obviously if you make the pure lua implementations track list length too then
they will likely just outperform the L-C library but you might as well have
written a library at that point
Output on my machine:
No library's accessing time is 0.0735980
L-C2's accessing time is 0.2945530
L-C's accessing time is 0.2921770
L-C's time is 1.0081 times faster than L-C2's
Pure lua's time is 3.9699 times faster than L-C
No library's mapping time is 0.1624200
L-C2's mapping time is 0.2945530
L-C's mapping time is 0.5600120
L-C2's time is 1.9012 times faster than L-C's
Pure lua's time is 1.8135 times faster than L-C2
No library's forEaching time is 0.0737490
L-C2's forEaching time is 0.0426070
L-C's forEaching time is 0.0408250
L-C's time is 1.0436 times faster than L-C2's
L-C's time is 1.8065 times faster than pure lua
No library's non existent contains check time is 0.0496680
L-C2's non existent contains check time is 0.0207680
L-C's non existent contains check time is 0.0211680
L-C2's time is 1.0193 times faster than L-C's
L-C2's time is 2.3916 times faster than pure lua
No library's filtering time is 0.2944590
L-C2's filtering time is 0.0846620
L-C's filtering time is 0.0824770
L-C's time is 1.0265 times faster than L-C2's
L-C's time is 3.5702 times faster than pure lua
No library's add all time is 0.2805630
L-C2's add all time is 0.0969620
L-C's add all time is 0.0982480
L-C2's time is 1.0133 times faster than L-C's
L-C2's time is 2.8935 times faster than pure lua
No library's get list of unique elements time is 1.0071950
L-C2's get list of unique elements time is 0.6014440
L-C's get list of unique elements time is 0.5976160
L-C's time is 1.0064 times faster than L-C2's
L-C's time is 1.6854 times faster than pure lua
]]--

