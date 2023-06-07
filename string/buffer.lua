local status, string_buffer = pcall(require, 'string.buffer')
if status then
	return string_buffer
end

local hasJIT = jit and jit.status()
local ffi_string = hasJIT and require 'ffi'.string

local hasClear, table_clear = pcall(require 'table.clear')
local table_concat = table.concat
local table_unpack = table.unpack or unpack -- luacheck: ignore 143
local string_format = string.format
local tostring = tostring

local buffer = {}
buffer.__index = buffer

function buffer.new(_size, _options)
	return setmetatable({chunks = {}, chunkCount = 0, len = 0}, buffer)
end

if hasClear then
	function buffer:reset()
		table_clear(self.chunks)
		self.chunkCount = 0
	end
else
	function buffer:reset()
		self.chunks = {}
		self.chunkCount = 0
	end
end

buffer.free = buffer.reset

function buffer:_putstr(str)
	self.chunkCount = self.chunkCount + 1
	self.chunks[self.chunkCount] = str
	self.len = self.len + #str
end

function buffer:put(value)
	self:_putstr(tostring(value))
end

function buffer:putf(format, ...)
	self:_putstr(string_format(format, ...))
end

if hasJIT then
	function buffer:putcdata(cdata, len)
		self:_putstr(ffi_string(cdata, len))
	end
else
	function buffer.putcdata(_self, _cdata, _len)
		error('this function is not available', 2)
	end
end

function buffer:set(str, len)
	self:reset()
	if len then
		self:putcdata(str, len)
	else
		self:put(str)
	end
end

function buffer.reserve(_self, _size)
	error 'not yet implemented'
end

function buffer.commit(_self, _used)
	error 'not yet implemented'
end

function buffer:__concat(other)
	return self:tostring() .. tostring(other)
end

function buffer:__len() -- Not always supported Sadge
	return self.len
end

function buffer:__tostring()
	return table_concat(self.chunks, nil, 1, self.chunkCount)
end

buffer.tostring = buffer.__tostring

function buffer:skip(len)
	assert(len ~= nil, "bad argument #1 to 'skip' (number expected, got no value)")
	self:get(len)
	return self
end

function buffer:get(...)
	local str = self:tostring()
	self:reset()
	if ... then
		local values = {...}
		local start, stop = 1
		for i = 1, select('#', ...) do
			stop = values[i] or (#str + 1)
			values[i] = str:sub(start, stop - 1)
			start = stop
		end
		self:_putstr(str:sub(start))
		return table_unpack(values)
	end
	return str
end

return buffer