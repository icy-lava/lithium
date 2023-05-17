local common = require('lithium.common')

local sort = table.sort

local ltable = setmetatable({
	pack    = common.pack,
	unpack  = common.unpack,
	isEmpty = common.isEmpty,
	get     = common.get,
	set     = common.set,
	delete  = common.delete,
	clear   = common.clear,
	ripairs = common.ripairs,
	keys    = common.keys,
	values  = common.values,
	array   = common.array,
	array2  = common.array2,
	empty   = common.empty,
}, {__index = table})

function ltable.copy(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[k] = v
	end
	return newT
end

function ltable.icopy(t)
	local newT = {}
	for i = 1, #t do
		newT[i] = t[i]
	end
	return newT
end

local function clone(t, refmap)
	if refmap[t] then
		return refmap[t]
	end
	local newT = {}
	refmap[t] = newT
	for k, v in pairs(t) do
		if type(v) == 'table' then
			newT[k] = clone(v, refmap)
		else
			newT[k] = v
		end
	end
	return newT
end

function ltable.clone(t)
	return clone(t, {})
end

function ltable.invert(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[v] = k
	end
	return newT
end

function ltable.merge(...)
	local result = ltable.copy((...))
	for i = 2, select('#', ...) do
		for k, v in pairs((select(i, ...))) do
			result[k] = v
		end
	end
	return result
end

function ltable.imerge(...)
	local result = ltable.icopy((...))
	local count = #result
	for i = 2, select('#', ...) do
		local subT = select(i, ...)
		for j = 1, #subT do
			count = count + 1
			result[count] = subT[j]
		end
	end
	return result
end

function ltable.push(t, ...)
	local len = #t
	for i = 1, select('#', ...) do
		local value = select(i, ...)
		if value ~= nil then
			len = len + 1
			t[len] = value
		end
	end
	return len
end

function ltable.map(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		newT[key] = func(value, ...)
	end
	return newT
end

function ltable.imap(t, func, ...)
	local newT = {}
	local len = 0
	for i = 1, #t do
		local value = func(t[i], ...)
		if value ~= nil then
			len = len + 1
			newT[len] = value
		end
	end
	return newT
end

function ltable.filter(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		if func(value, ...) then
			newT[key] = value
		end
	end
	return newT
end

function ltable.ifilter(t, func, ...)
	local newT = {}
	local newCount = 0
	for i = 1, #t do
		local value = t[i]
		if func(value, ...) then
			newCount = newCount + 1
			newT[newCount] = value
		end
	end
	return newT
end

function ltable.reject(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		if not func(value, ...) then
			newT[key] = value
		end
	end
	return newT
end

function ltable.ireject(t, func, ...)
	local newT = {}
	local newCount = 0
	for i = 1, #t do
		local value = t[i]
		if not func(value, ...) then
			newCount = newCount + 1
			newT[newCount] = value
		end
	end
	return newT
end

function ltable.each(t, func)
	for k, v in pairs(t) do
		if func(k, v) == false then
			return
		end
	end
end

function ltable.ieach(t, func)
	for i, v in ipairs(t) do
		if func(i, v) == false then
			return
		end
	end
end

function ltable.sort(t, comp)
	if comp == nil or 'function' == type(comp) then
		sort(t, comp)
	else
		sort(t, function(a, b)
			return a[comp] < b[comp]
		end)
	end
end

-- Sort by key by default
local function spairsDefaultComparator(a, b)
	return a[1] < b[1]
end

function ltable.spairs(t, comp)
	local set = ltable.array2(pairs(t))
	sort(set, comp or spairsDefaultComparator)
	
	local cor = coroutine.wrap(function()
		for _, kv in ipairs(set) do
			coroutine.yield(kv[1], kv[2])
		end
	end)
	
	return cor
end

function ltable.reverse(t)
	local newT = {}
	local len = 0
	for i = #t, 1, -1 do
		len = len + 1
		newT[len] = t[i]
	end
	return newT
end

local defaultReducer = function(a, b) return a + b end
function ltable.reduce(t, reducer)
	if reducer == nil then
		reducer = defaultReducer
	end
	local value = t[1]
	for i = 2, t.n or #t do
		value = reducer(value, t[i])
	end
	return value
end

local _, table_new = pcall(require, 'table.new')
ltable.new = table_new or function() return {} end

return ltable
