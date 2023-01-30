local wrap, yield = coroutine.wrap, coroutine.yield
local array = require('lithium.common').array

local stringx = setmetatable({}, {__index = string})

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

function stringx.delim(str, delim, isPattern)
	local iter = wrap(delimIterator)
	iter(str, delim, not isPattern)
	return iter
end

function stringx.lines(str)
	return stringx.delim(str, '\r?\n', true)
end

function stringx.lineAt(str, i, newlinePattern)
	if newlinePattern == nil then
		newlinePattern = '\n'
	end
	local line = 1
	for _ in str:sub(1, i - 1):gmatch(newlinePattern) do
		line = line + 1
	end
	return line
end

function stringx.positionAt(str, i, newlinePattern)
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

function stringx.split(...)
	return array(stringx.delim(...))
end

function stringx.startsWith(str, prefix)
	return prefix == str:sub(1, #prefix)
end

function stringx.endsWith(str, suffix)
	return suffix == str:sub(-#suffix, -1)
end

function stringx.contains(str, substr)
	return not not str:find(substr, 1, true)
end

function stringx.trimLeft(str)
	return (str:gsub('^%s+', '', 1))
end

function stringx.trimRight(str)
	return (str:gsub('%s+$', '', 1))
end

function stringx.trim(str)
	return stringx.trimLeft(stringx.trimRight(str))
end

function stringx.trimNonEmpty(str)
	str = stringx.trim(str)
	if str == '' then
		return nil
	end
	return str
end

return stringx
