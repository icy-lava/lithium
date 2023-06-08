local wrap, yield = coroutine.wrap, coroutine.yield
local common = require 'lithium.common'

local lstring = setmetatable({
	quote  = common.quote,
	pretty = common.pretty,
}, {__index = string})

local function delimIterator(str, delim, plain)
	yield()
	local i, strlen = 1, #str
	while true do
		local start, stop = str:find(delim, i, plain)
		if start then
			if stop < start then
				stop = stop + 1
				start = start + 1
			end
			yield(str:sub(i, start - 1))
			i = stop + 1
			if i > strlen then
				if start <= stop then
					yield('')
				end
				break
			end
		else
			yield(str:sub(i, strlen))
			break
		end
	end
	while true do
		yield(nil)
	end
end

function lstring.delim(str, delim, isPattern)
	local iter = wrap(delimIterator)
	iter(str, delim, not isPattern)
	return iter
end

function lstring.lines(str)
	return lstring.delim(str, '\r?\n', true)
end

function lstring.lineAt(str, i, newlinePattern)
	if newlinePattern == nil then
		newlinePattern = '\n'
	end
	local line = 1
	for _ in str:sub(1, i - 1):gmatch(newlinePattern) do
		line = line + 1
	end
	return line
end

function lstring.positionAt(str, i, newlinePattern)
	if newlinePattern == nil then
		newlinePattern = '\n'
	end
	if i > #str then
		return nil, 'index is out of range'
	end
	local line = 1
	local j = 1
	while j < i do
		local start, stop = str:find(newlinePattern, j)
		if not start or stop >= i then
			break
		end
		if stop < j then
			return nil, 'newline pattern matches empty string'
		end
		j = stop + 1
		line = line + 1
	end
	return line, i - j + 1
end

function lstring.split(...)
	return common.array(lstring.delim(...))
end

function lstring.startsWith(str, prefix)
	return prefix == str:sub(1, #prefix)
end

function lstring.endsWith(str, suffix)
	return suffix == str:sub(-#suffix, -1)
end

function lstring.contains(str, substr)
	return not not str:find(substr, 1, true)
end

function lstring.trimLeft(str)
	return (str:gsub('^%s+', '', 1))
end

function lstring.trimRight(str)
	return (str:gsub('%s+$', '', 1))
end

function lstring.trim(str)
	return lstring.trimLeft(lstring.trimRight(str))
end

function lstring.trimNonEmpty(str)
	str = lstring.trim(str)
	if str == '' then
		return nil
	end
	return str
end

local string_format = string.format
local function lstring_format(format, t)
	return (format:gsub('%b{}', function(key)
		key = key:sub(2, -2)
		local value = t[tonumber(key) or key]
		if value ~= nil then
			return tostring(value)
		end
		return string_format('{%s}', lstring_format(key, t))
	end))
end

lstring.format = lstring_format

return lstring
