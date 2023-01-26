local common = require('lithium.common')
local pack, unpack, isEmpty, index, set, delete, clear, ripairs, keys, array, empty = common.pack, common.unpack, common.isEmpty, common.index, common.set, common.delete, common.clear, common.ripairs, common.keys, common.array, common.empty

local sort = table.sort

local tablex = {
	pack = pack,
	unpack = unpack,
	isEmpty = isEmpty,
	index = index,
	set = set,
	delete = delete,
	clear = clear,
	ripairs = ripairs,
	keys = keys,
	array = array,
	empty = empty
}

function tablex.copy(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[k] = v
	end
	return newT
end

function tablex.icopy(t)
	local newT = {}
	for i = 1, #t do
		newT[i] = t[i]
	end
	return newT
end

function tablex.clone(value)
	if 'table' ~= type(value) then
		return value
	end
	local newT = {}
	for k, v in pairs(value) do
		newT[k] = tablex.clone(v)
	end
	return newT
end

function tablex.invert(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[v] = k
	end
	return newT
end

function tablex.merge(...)
	local result = tablex.copy((...))
	for i = 2, select('#', ...) do
		for k, v in pairs((select(i, ...))) do
			result[k] = v
		end
	end
	return result
end

function tablex.imerge(...)
	local result = tablex.icopy((...))
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

function tablex.map(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		newT[key] = func(value, ...)
	end
	return newT
end

function tablex.imap(t, func, ...)
	local newT = {}
	local len = 0
	for i = 1, #t do
		len = len + 1
		newT[len] = func(t[i], ...)
	end
	return newT
end

function tablex.filter(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		if func(value, ...) then
			newT[key] = value
		end
	end
	return newT
end

function tablex.ifilter(t, func, ...)
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

function tablex.reject(t, func, ...)
	local newT = {}
	for key, value in pairs(t) do
		if not func(value, ...) then
			newT[key] = value
		end
	end
	return newT
end

function tablex.ireject(t, func, ...)
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

function tablex.sort(t, comp)
	local newT = tablex.icopy(t)
	if comp == nil or 'function' == type(comp) then
		sort(newT, comp)
	else
		sort(newT, function(a, b)
			return a[comp] < b[comp]
		end)
	end
	return newT
end

function tablex.reverse(t)
	local newT = {}
	local len = 0
	for i = #t, 1, -1 do
		len = len + 1
		newT[len] = t[i]
	end
	return newT
end

local defaultReducer = function(a, b) return a + b end
function tablex.reduce(t, reducer)
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
tablex.new = table_new or function() return {} end

return tablex
