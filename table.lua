local common = require('lithium.common')

local sort = table.sort

local ltable = setmetatable({
	pack       = common.pack,
	unpack     = common.unpack,
	toPacked   = common.toPacked,
	toUnpacked = common.toUnpacked,
	sub        = common.sub,
	isEmpty    = common.isEmpty,
	get        = common.get,
	set        = common.set,
	delete     = common.delete,
	clear      = common.clear,
	ripairs    = common.ripairs,
	keys       = common.keys,
	values     = common.values,
	array      = common.array,
	array2     = common.array2,
	empty      = common.empty,
}, {__index = table})

local function equal(a, b)
	if type(a) == 'table' and type(b) == 'table' then
		for k, av in pairs(a) do
			if not equal(av, b[k]) then
				return false
			end
		end
		for k, bv in pairs(b) do
			if not equal(a[k], bv) then
				return false
			end
		end
		return true
	end
	return a == b
end
ltable.equal = equal

local function iequal(a, b)
	if type(a) == 'table' and type(b) == 'table' then
		local alen = #a
		if alen ~= #b then return false end
		for i = 1, alen do
			if not equal(a[i], b[i]) then
				return false
			end
		end
		return true
	end
	return a == b
end
ltable.iequal = iequal

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
	if refmap[t] ~= nil then
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

function ltable.find(t, value)
	for k, other in pairs(t) do
		if value == other then
			return k
		end
	end
	return nil
end

function ltable.ifind(t, value)
	for i = 1, #t do
		if value == t[i] then
			return i
		end
	end
	return nil
end

function ltable.count(t, value)
	local count = 0
	for _, other in pairs(t) do
		if value == other then
			count = count + 1
		end
	end
	return count
end

function ltable.countKeys(t, key)
	local count = 0
	for otherKey in pairs(t) do
		if key == otherKey then
			count = count + 1
		end
	end
	return count
end

function ltable.icount(t, value)
	local count = 0
	for i = 1, #t do
		if value == t[i] then
			count = count + 1
		end
	end
	return count
end

function ltable.mergeInto(dest, ...)
	for i = 1, select('#', ...) do
		for k, v in pairs((select(i, ...))) do
			dest[k] = v
		end
	end
	return dest
end

function ltable.imergeInto(dest, ...)
	local count = #dest
	for i = 1, select('#', ...) do
		local subT = select(i, ...)
		for j = 1, #subT do
			count = count + 1
			dest[count] = subT[j]
		end
	end
	return dest
end

function ltable.merge(...)
	return ltable.mergeInto({}, ...)
end

function ltable.imerge(...)
	return ltable.imergeInto({}, ...)
end

function ltable.flatten(t)
	local result = {}
	for i = 1, #t do
		for k, v in pairs(t[i]) do
			result[k] = v
		end
	end
	return result
end

function ltable.iflatten(t)
	local result = {}
	local count = 0
	for i = 1, #t do
		local subT = t[i]
		for j = 1, #subT do
			count = count + 1
			result[count] = subT[j]
		end
	end
	return result
end

function ltable.reverse(t, count)
	count = count or #t
	for i = 1, count / 2 do
		local j = count - i + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
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
	return t
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

function ltable.spairs(t, comp)
	local keys = ltable.keys(t)
	sort(keys, comp)
	
	local i = 0
	return function()
		i = i + 1
		local key = keys[i]
		if key ~= nil then
			return key, t[key]
		end
		return nil
	end
end

local defaultReducer = function(a, b) return a + b end
function ltable.reduce(t, reducer)
	reducer = reducer or defaultReducer
	local value = t[1]
	for i = 2, t.n or #t do
		value = reducer(value, t[i])
	end
	return value
end

local _, table_new = pcall(require, 'table.new')
ltable.new = table_new or function() return {} end

return ltable
