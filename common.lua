local _, table_clear = pcall(require, 'table.clear')

local common = {}

local ripairsIterator = function(t, i)
	if i == 1 then
		return nil
	end
	i = i - 1
	return i, t[i]
end

function common.noop() end
function common.pass(...) return ... end

common.empty = setmetatable({}, {
	__metatable = false,
	__newindex = function() end
})

function common.isEmpty(t)
	return nil == next(t)
end

function common.array(...)
	local arr = {}
	local length = 0
	for v in ... do
		length = length + 1
		arr[length] = v
	end
	return arr
end

function common.array2(...)
	local arr = {}
	local length = 0
	for v1, v2 in ... do
		length = length + 1
		arr[length] = {v1, v2}
	end
	return arr
end

function common.index(t, ...)
	for i = 1, select('#', ...) do
		if type(t) ~= 'table' then
			return nil
		end
		t = t[select(i, ...)]
	end
	return t
end

function common.set(t, ...)
	local argLen = select('#', ...)
	assert(argLen > 0)
	if argLen == 1 then
		return (...)
	end
	for i = 1, argLen - 2 do
		local key = select(i, ...)
		if t[key] == nil then
			t[key] = {}
		end
		t = t[key]
		assert(type(t) ~= 'string', 'tried to index a string, but it\'s not allowed')
	end
	t[select(argLen - 1, ...)] = select(argLen, ...)
	return t
end

function common.delete(t, ...)
	local argLen = select('#', ...)
	assert(argLen > 0)
	if argLen == 1 then
		local key = ...
		t[key] = nil
		if common.isEmpty(t) then
			return nil
		end
		return t
	end
	local path = {
		t
	}
	for i = 1, argLen - 1 do
		local key = select(i, ...)
		t = t[key]
		if type(t) ~= 'table' then
			return path[1]
		end
		path[i + 1] = t
	end
	for i = argLen, 1, -1 do
		local key = select(i, ...)
		t = path[i]
		t[key] = nil
		if not common.isEmpty(t) then
			return path[1]
		end
	end
	return nil
end

common.clear = table_clear or function(t)
	for k in pairs(t) do
		rawset(t, k, nil)
	end
	return t
end

common.pack = table.pack or function(...)
	return {
		n = select('#', ...),
		...
	}
end

function common.packCaptures(start, stop, ...)
	return start, stop, common.pack(...)
end

common.unpack = table.unpack or unpack

function common.ripairs(t)
	return ripairsIterator, t, #t + 1
end

function common.keys(t)
	return common.array(pairs(t))
end

return common