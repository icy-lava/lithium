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

local function singleToMulti(func)
	return function(...)
		local count = select('#', ...)
		local values = {}
		for i = 1, count do
			values[i] = func((select(i, ...)))
		end
		return common.unpack(values, 1, count)
	end
end

local format = string.format
local function quote(value)
	return format('%q', value)
end

common.quote = singleToMulti(quote)

local function indentation(indent)
	return ('    '):rep(indent)
end

local function pretty(value, indent, refmap)
	indent = indent or 0
	local vtype = type(value)
	if vtype == 'string' then
		return quote(value)
	elseif vtype == 'number' or vtype == 'boolean' then
		return tostring(value)
	end
	
	refmap = refmap or {}
	
	if vtype == 'table' and not refmap[value] then
		if common.isEmpty(value) then
			return '{}'
		end
		
		refmap[value] = true
		
		local sequential = {}
		local maxI = -1
		local count = 0
		local isArray = true
		for k in pairs(value) do
			if type(k) == 'number' and k >= 1 and k % 1 == 0 then
				table.insert(sequential, k)
				maxI = math.max(maxI, k)
			else
				isArray = false
			end
			count = count + 1
		end
		
		if isArray and count == maxI then
			local str = {}
			for _, v in ipairs(value) do
				table.insert(str, pretty(v, indent, refmap))
			end
			return format('{%s}', table.concat(str, ', '))
		end
		
		indent = indent + 1
		
		local str = {'{\n'}
		for k, v in pairs(value) do
			if type(k) == 'string' then
				if not k:match('^[%a_][%w_]*$') then
					k = format('[%q]', k)
				end
			else
				k = format('[%s]', pretty(k, 0, refmap))
			end
			table.insert(str, format('%s%s = %s,\n', indentation(indent), k, pretty(v, indent, refmap)))
		end
		indent = indent - 1
		
		table.insert(str, indentation(indent))
		table.insert(str, '}')
		
		return table.concat(str)
	end
	
	return format('<%s>', value)
end

common.pretty = singleToMulti(pretty)

function common.pprint(...)
	local values = {}
	for i = 1, select('#', ...) do
		values[i] = pretty((select(i, ...)))
	end
	print(table.concat(values, ', '))
end

return common