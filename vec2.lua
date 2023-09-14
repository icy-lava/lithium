local format = string.format
local min = math.min
local max = math.max
local abs = math.abs
local atan2 = math.atan2 or math.atan
local cos = math.cos
local sin = math.sin

local vec2 = {}

setmetatable(vec2, {__call = function(_, ...) return vec2.new(...) end})

function vec2.new(x, y)
	x = x or 0
	return setmetatable({x = x, y = y or x}, vec2)
end

function vec2.fromPolar(angle, length)
	length = length or 1
	return vec2.new(cos(angle) * length, sin(angle) * length)
end

function vec2.fromLoveMouse()
	return vec2.new(love.mouse.getPosition())
end

function vec2.fromLoveDimensions()
	return vec2.new(love.graphics.getDimensions())
end

function vec2.fromLoveMode()
	local width, height = love.window.getMode()
	return vec2.new(width, height)
end

function vec2:__add(other)
	return vec2.new(self.x + other.x, self.y + other.y)
end

function vec2:__sub(other)
	return vec2.new(self.x - other.x, self.y - other.y)
end

function vec2:__mul(other)
	if type(self) == 'number' then
		return vec2.new(self * other.x, self * other.y)
	end
	if type(other) == 'number' then
		return vec2.new(self.x * other, self.y * other)
	end
	return vec2.new(self.x * other.x, self.y * other.y)
end

function vec2:__div(other)
	if type(other) == 'number' then
		return vec2.new(self.x / other, self.y / other)
	end
	return vec2.new(self.x / other.x, self.y / other.y)
end

function vec2:__mod(other)
	return vec2.new(self.x % other.x, self.y % other.y)
end

function vec2:__pow(other)
	if type(other) == 'number' then
		return vec2.new(self.x ^ other, self.y ^ other)
	end
	return vec2.new(self.x ^ other.x, self.y ^ other.y)
end

function vec2:__unm()
	return vec2.new(-self.x, -self.y)
end

function vec2:__eq(other)
	return self.x == other.x and self.y == other.y
end

function vec2:__lt(other)
	return self.x < other.x and self.y < other.y
end

function vec2:__le(other)
	return self.x <= other.x and self.y <= other.y
end

function vec2:__tostring()
	return format('vec2 {%s, %s}', self.x, self.y)
end

function vec2:set(x, y)
	x = x or 0
	if type(x) ~= 'number' then
		x, y = x.x, x.y
	end
	self.x, self.y = x, y or x
end

function vec2:dot(other)
	return self.x * other.x + self.y + other.y
end

function vec2:cross(other)
	return self.x * other.y - other.x * self.y
end

function vec2:dist(other)
	return ((self.x - other.x) ^ 2 + (self.y - other.y) ^ 2) ^ 0.5
end

function vec2:dist2(other)
	return (self.x - other.x) ^ 2 + (self.y - other.y) ^ 2
end

function vec2:delta(other)
	return vec2.new(other.x - self.x, other.y - self.y)
end

function vec2:lerp(t, other)
	local it = 1 - t
	return vec2.new(self.x * it + other.x * t, self.y * it + other.y * t)
end

function vec2:split()
	return self.x, self.y
end

function vec2:min(...)
	local minX, minY = self.x, self.y
	for i = 1, select('#', ...) do
		local other = select(i, ...)
		minX, minY = min(minX, other.x), min(minY, other.y)
	end
	return vec2.new(minX, minY)
end

function vec2:minCoord()
	return min(self.x, self.y)
end

function vec2:max(...)
	local maxX, maxY = self.x, self.y
	for i = 1, select('#', ...) do
		local other = select(i, ...)
		maxX, maxY = max(maxX, other.x), max(maxY, other.y)
	end
	return vec2.new(maxX, maxY)
end

function vec2:maxCoord()
	return max(self.x, self.y)
end

function vec2:bounds(...)
	local minX, minY, maxX, maxY = self.x, self.y, self.x, self.y
	for i = 1, select('#', ...) do
		local other = select(i, ...)
		local ox, oy = other.x, other.y
		minX, minY = min(minX, ox), min(minY, oy)
		maxX, maxY = max(maxX, ox), max(maxY, oy)
	end
	return vec2.new(minX, minY), vec2.new(maxX, maxY)
end

function vec2:perp()
	return vec2.new(-self.y, self.x)
end

function vec2:polar()
	return atan2(self.y, self.x), (self.x ^ 2 + self.y ^ 2) ^ 0.5
end

function vec2:rotate(delta)
	self:setAngle(self:getAngle() + delta)
end

function vec2:rotated(delta)
	local angle = self:getAngle() + delta
	local length = self:getLength()
	return vec2.new(cos(angle) * length, sin(angle) * length)
end

function vec2:loveMouse()
	love.mouse.setPosition(self.x, self.y)
end

function vec2:loveMode()
	love.window.updateMode(self.x, self.y, {})
end

function vec2:getAngle()
	return atan2(self.y, self.x)
end

function vec2:setAngle(angle)
	local length = self:getLength()
	self.x, self.y = cos(angle) * length, sin(angle) * length
end

function vec2:getLength()
	return (self.x ^ 2 + self.y ^ 2) ^ 0.5
end

function vec2:setLength(value)
	local length = self:getLength()
	if length ~= 0 then
		local mul = value / length
		self.x, self.y = self.x * mul, self.y * mul
	else
		self.x, self.y = value, 0
	end
end

function vec2:getLength2()
	return self.x ^ 2 + self.y ^ 2
end

function vec2:setLength2(value)
	self:setLength(abs(value) ^ 0.5)
end

function vec2:getNormal()
	local length = (self.x ^ 2 + self.y ^ 2) ^ 0.5
	return vec2.new(self.x / length, self.y / length)
end

function vec2:getCopy()
	return vec2.new(self.x, self.y)
end

local getters = {
	angle = vec2.getAngle,
	length = vec2.getLength,
	length2 = vec2.getLength2,
	normal = vec2.getNormal,
	copy = vec2.getCopy,
}

function vec2:__index(key)
	local field = vec2[key]
	if field ~= nil then
		return field
	end
	local getter = getters[key]
	if getter then
		return getter(self)
	end
	return nil
end

local setters = {
	angle = vec2.setAngle,
	length = vec2.setLength,
	length2 = vec2.setLength2,
}

function vec2:__setindex(key, value)
	local setter = setters[key]
	if setter then
		return setter(self, value)
	end
	rawset(self, key, value)
end

return vec2