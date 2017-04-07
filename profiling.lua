local profiler = {}

-- other
local oList1
local oList2

local sList1
local sList2

local sName
local oName

-- for running see profiler.run method at bottom of file
-- all times outputted are in seconds
local function run()

-- this file also compares against a pure lua approach
-- 'vanilla'
-- due to the implementation of L-C as a single metatable for
-- a standard table, where pure lua drastically outperforms
-- such as in access and mapping, pure lua can be used
-- anyway to take the speed when it is needed
local vList1 = {}
local vList2 = {}

local startClock = os.clock()

-- To replace with another system
startClock = os.clock()
for i = 0, 1000000 do
	oList1:add(i)
	oList1:get(i)
	oList2:add(i)
	oList2:get(i)
end
local oTime = os.clock() - startClock

-- Lua Collections
startClock = os.clock()
for i = 0, 1000000 do
	sList1:add(i)
  sList1:get(i)
	sList2:add(i)
  sList2:get(i)
end
local sTime = os.clock() - startClock

-- pure lua
startClock = os.clock()
for i = 0, 1000000 do
    vList1[i] = i
    local got = vList1[i]
	  vList2[i] = i
    got = vList2[i]
end
local vTime = os.clock() - startClock

function displayResults(resultType)
  print("No library's " .. resultType .. " time is " .. string.format("%2.7f", vTime))
  print(oName .. "'s " .. resultType .. " time is " .. string.format("%2.7f", oTime))
  print(sName .. "'s " .. resultType .. " time is " .. string.format("%2.7f", sTime))
  if oTime/sTime > 1 then
    print(sName .. "'s time is " .. string.format("%4.4f", oTime/sTime) 
      .. " times faster than " .. oName .. "'s")
    if vTime/sTime > 1 then
      print(sName .. "'s time is " .. string.format("%4.4f", vTime/sTime)
        .. " times faster than pure lua")
    else
      print("Pure lua's time is " .. string.format("%4.4f", sTime/vTime)
        .. " times faster than " .. sName)
    end
  else
    print(oName .. "'s time is " .. string.format("%4.4f", sTime/oTime) 
      .. " times faster than " .. sName .. "'s")
    if vTime/oTime > 1 then
      print(oName .. "'s time is " .. string.format("%4.4f", vTime/oTime)
        .. " times faster than pure lua")
    else
      print("Pure lua's time is " .. string.format("%4.4f", oTime/vTime)
        .. " times faster than " .. oName)
    end
  end
end

displayResults("accessing")

local function map(value)
  return value*2
end

startClock = os.clock()
for i = 0, 5 do
    oList1 = oList1:map(map)
end
sTime = os.clock() - startClock

startClock = os.clock()
for i = 0, 5 do
    sList1 = sList1:map(map)
end
sTime = os.clock() - startClock

startClock = os.clock()
for i = 0, 5 do
  for j = 0, #vList1 do
    vList1[j] = vList1[j]*2
  end
end
vTime = os.clock() - startClock

displayResults("mapping")

local total = 0
local function consumer(item)
  total = total + item
end

total = 0
startClock = os.clock()
oList1:forEach(consumer)
oTime = os.clock() - startClock

total = 0
startClock = os.clock() 		
sList1:forEach(consumer)
sTime = os.clock() - startClock

total = 0
startClock = os.clock()
for k, v in ipairs(vList1) do
  consumer(v)
end
vTime = os.clock() - startClock

displayResults("forEaching")


startClock = os.clock()
oList1:contains(0.2)
oTime = os.clock() - startClock

startClock = os.clock()
sList1:contains(0.2)
sTime = os.clock() - startClock

contains = false
function contains()
  for k, v in ipairs(vList1) do
    if v == 0.2 then
      contains = true
      return
    end
  end
end
startClock = os.clock()
contains()
vTime = os.clock() - startClock

displayResults("non existent contains check")

local function predicate(item)
  if item % 2 == 0 then
    return true
  end
end

total = 0
startClock = os.clock()
oList1:filter(predicate)
oTime = os.clock() - startClock

total = 0
startClock = os.clock()
sList1:filter(predicate)
sTime = os.clock() - startClock

total = 0
startClock = os.clock() 
local filtered = {}
for k, v in ipairs(vList1) do
  if predicate(v) then
    filtered[#filtered+1] = v
  end
end
vTime = os.clock() - startClock

displayResults("filtering")

startClock = os.clock()
oList1:addAll(sList2)
oTime = os.clock() - startClock

startClock = os.clock()
sList1:addAll(sList2)
sTime = os.clock() - startClock

startClock = os.clock()
for k, v in ipairs(vList2) do
  vList1[#vList1+1] = v
end
vTime = os.clock() - startClock

displayResults("add all")

startClock = os.clock()
oList1:asSet()
oTime = os.clock() - startClock

startClock = os.clock()
sList1:asSet()
sTime = os.clock() - startClock

startClock = os.clock()
local seen = {}
local unique = {}
for k, v in ipairs(vList1) do
  if not seen[v] then
    unique[#unique+1] = v
    seen[v] = true
  end
end
vTime = os.clock() - startClock

displayResults("get list of unique elements")

end -- end run

-- pass in the lists here
-- s1 and s2 are for the first library, and o1 and o2 for the second
-- then sN and oN are the respective names to refer to them in
-- printed output
function profiler.run(s1, s2, o1, o2, sN, oN)
  sList1 = s1
  sList2 = s2
  oList1 = o1
  oList2 = o2
  sName = sN
  oName = oN
  run()
end

return profiler
