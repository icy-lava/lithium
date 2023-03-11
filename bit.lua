if jit then
	return require 'bit'
end

local bit = {}

local loadstring = loadstring or load
local format = string.format
local floor = math.floor
local ceil = math.ceil

local function round(x)
	if x < 0 then
		return ceil(x - 0.5)
	else
		return floor(x + 0.5)
	end
end

local function normalize(x)
	return round(x) % 2 ^ 32
end

local function normalizeShift(n)
	return round(n) % 2 ^ 5
end

local function uint2int(x)
	if x >= 2 ^ 31 then
		return x - 2 ^ 32
	end
	return x
end

function bit.tobit(x)
	return uint2int(normalize(x))
end

function bit.tohex(x, n)
	if n == 0 then
		return ''
	end
	n = n or 8
	
	local upper = false
	if n < 0 then
		n = -n
		upper = true
	end
	
	x = normalize(x)
	
	local str
	if upper then
		str = format('%08X', x)
	else
		str = format('%08x', x)
	end
	
	return ('0'):rep(n - 8) .. str:sub(-n)
end

function bit.bnot(x)
	return uint2int(normalize(-round(x) - 1))
end

local logicTemplate = [[
	return function(a, ...)
		a = (a + 0.5) % 2 ^ 32
		local result
		for i = 1, select('#', ...) do
			result = 0
			local b = (select(i, ...) + 0.5) % 2 ^ 32
			{body}
			a = result
		end
		if result >= 2 ^ 31 then
			result = result - 2 ^ 32
		end
		return result
	end
]]

do
	local cycle = [[
		if a >= {c} then
			if b >= {c} then
				b = b - {c}
			end
			result = result + {c}
			a = a - {c}
		elseif b >= {c} then
			result = result + {c}
			b = b - {c}
		end
	]]
	
	local t = {}
	for i = 31, 0, -1 do
		table.insert(t, (cycle:gsub('{c}', 2 ^ i)))
	end
	
	local src = logicTemplate:gsub('{body}', table.concat(t))
	bit.bor = assert(loadstring(src))()
end

do
	local cycle = [[
		if a >= {c} then
			if b >= {c} then
				result = result + {c}
				b = b - {c}
			end
			a = a - {c}
		elseif b >= {c} then
			b = b - {c}
		end
	]]
	
	local t = {}
	for i = 31, 0, -1 do
		table.insert(t, (cycle:gsub('{c}', 2 ^ i)))
	end
	
	local src = logicTemplate:gsub('{body}', table.concat(t))
	bit.band = assert(loadstring(src))()
end

do
	local cycle = [[
		if a >= {c} then
			if b >= {c} then
				b = b - {c}
			else
				result = result + {c}
			end
			a = a - {c}
		elseif b >= {c} then
			result = result + {c}
			b = b - {c}
		end
	]]
	
	local t = {}
	for i = 31, 0, -1 do
		table.insert(t, (cycle:gsub('{c}', 2 ^ i)))
	end
	
	local src = logicTemplate:gsub('{body}', table.concat(t))
	bit.bxor = assert(loadstring(src))()
end

function bit.lshift(x, n)
	n = normalizeShift(n)
	return uint2int(round(x) % 2 ^ (32 - n) * 2 ^ (n))
end

function bit.rshift(x, n)
	n = normalizeShift(n)
	x = normalize(x)
	return uint2int(floor(x / 2 ^ n))
end

function bit.arshift(x, n)
	n = normalizeShift(n)
	x = normalize(x)
	local result = floor(x / 2 ^ n)
	if x >= 2 ^ 31 then
		result = result + (2 ^ n - 1) * 2 ^ (32 - n)
	end
	return uint2int(result)
end

function bit.rol(x, n)
	n = normalizeShift(n)
	x = normalize(x)
	local low = x % 2 ^ (32 - n)
	return uint2int(
		(x - low) / 2 ^ (32 - n) +
		low * 2 ^ n
	)
end

function bit.ror(x, n)
	n = normalizeShift(n)
	x = normalize(x)
	local low = x % 2 ^ n
	return uint2int(
		(x - low) / 2 ^ n +
		low * 2 ^ (32 - n)
	)
end

function bit.bswap(x)
	x = normalize(x)
	local b1 = x % (2 ^ 8)
	local b2 = x % (2 ^ 16)
	local b3 = x % (2 ^ 24)
	return uint2int(
		b1 * 2 ^ 24 +
		(b2 - b1) * 2 ^ 8 +
		(b3 - b2) / 2 ^ 8 +
		(x - b3) / 2 ^ 24
	)
end

return bit