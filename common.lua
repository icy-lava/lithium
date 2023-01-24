local _, table_clear = pcall(require, 'table.clear')

local ripairsIterator = function(t, i)
	if i == 1 then
		return nil
	end
	i = i - 1
	return i, t[i]
end

local keysIterator = function(t, k)
	k = next(t, k)
	return k
end

local common
common = {
	noop = function() end,
	empty = setmetatable({}, {
		__metatable = false,
		__newindex = function() end
	}),
	isEmpty = function(t)
		return nil == next(t)
	end,
	index = function(t, ...)
		for i = 1, select('#', ...) do
			if not ('table' == type(t)) then
				return nil
			end
			t = t[select(i, ...)]
		end
		return t
	end,
	set = function(t, ...)
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
			assert('string' ~= type(t), 'tried to index a string, but it\'s not allowed')
		end
		t[select(argLen - 1, ...)] = select(argLen, ...)
		return t
	end,
	delete = function(t, ...)
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
			if 'table' ~= type(t) then
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
	end,
	clear = table_clear or function(t)
		for k in pairs(t) do
			rawset(t, k, nil)
		end
		return t
	end,
	pack = table.pack or function(...)
		return {
			n = select('#', ...),
			...
		}
	end,
	packCaptures = function(start, stop, ...)
		return start, stop, common.pack(...)
	end,
	unpack = table.unpack or unpack,
	ripairs = function(t)
		return ripairsIterator, t, #t + 1
	end,
	keys = function(t)
		return keysIterator, t
	end,
	array = function(...)
		local arr = {}
		local length = 0
		for v in ... do
			length = length + 1
			arr[length] = v
		end
		return arr
	end
}

return common