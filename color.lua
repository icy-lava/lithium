local color = {}
color.__index = color

local atan = math.atan2 or math.atan
local sin, cos = math.sin, math.cos
local max = math.max
local deg = math.deg
local rad = math.rad
local format = string.format

local function rgb2oklab(r, g, b, alpha)
	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
	
	local _l = l ^ (1 / 3)
	local _m = m ^ (1 / 3)
	local _s = s ^ (1 / 3)
	
	local L = 0.2104542553 * _l + 0.7936177850 * _m - 0.0040720468 * _s
	local a = 1.9779984951 * _l - 2.4285922050 * _m + 0.4505937099 * _s
	local b = 0.0259040371 * _l + 0.7827717662 * _m - 0.8086757660 * _s -- luacheck: ignore 412
	
	return L, a, b, alpha
end

local function oklab2rgb(L, a, b, alpha)
    local _l = L + 0.3963377774 * a + 0.2158037573 * b;
    local _m = L - 0.1055613458 * a - 0.0638541728 * b;
    local _s = L - 0.0894841775 * a - 1.2914855480 * b;
	
	local l = _l ^ 3
	local m = _m ^ 3
	local s = _s ^ 3
	
	local r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
	local g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
	local b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s -- luacheck: ignore 412
	
	return r, g, b, alpha
end

local function oklab2oklch(L, a, b, alpha)
	return L, (a ^ 2 + b ^ 2) ^ 0.5, atan(b, a), alpha
end

function color.oklab(l, a, b, alpha)
	assert(l and a and b)
	return setmetatable({l = l, a = a, b = b, alpha = alpha or 1}, color)
end

function color.rgb(r, g, b, alpha)
	assert(r and g and b)
	local obj = {}
	obj.l, obj.a, obj.b, obj.alpha = rgb2oklab(r, g, b, alpha or 1)
	return setmetatable(obj, color)
end

function color:__tostring()
	local l, c, h = oklab2oklch(self.l, self.a, self.b)
	return format(
		'oklch {lightness = %d%%, chroma = %0.2f, hue = %d deg, alpha = %d%%}',
		l * 100 + 0.5, c, deg(h) + 0.5, self.alpha * 100 + 0.5
	)
end

function color:lerp(t, other)
	local m = 1 - t
	return color.oklab(
		self.l * m + other.l * t,
		self.a * m + other.a * t,
		self.b * m + other.b * t,
		self.alpha * m + other.alpha * t
	)
end

function color:splitOklab()
	return self.l, self.a, self.b, self.alpha
end

function color:splitRGB()
	return oklab2rgb(self.l, self.a, self.b, self.alpha)
end

function color:array()
	return {self:splitRGB()}
end

function color:withAlpha(alpha)
	return color.oklab(self.l, self.a, self.b, alpha)
end

function color:addedAlpha(alpha)
	return color.oklab(self.l, self.a, self.b, self.alpha + alpha)
end

function color:withLightness(lightness)
	return color.oklab(lightness, self.a, self.b, self.alpha)
end

function color:addedLightness(lightness)
	return color.oklab(self.l + lightness, self.a, self.b, self.alpha)
end

function color:withChroma(c)
	local actual = (self.a ^ 2 + self.b ^ 2) ^ 0.5
	if actual > 0 then
		local mul = c / actual
		return color.oklab(self.l, self.a * mul, self.b * mul, self.alpha)
	end
	return color.oklab(self.l, c, 0, self.alpha)
end

function color:addedChroma(c)
	local actual = (self.a ^ 2 + self.b ^ 2) ^ 0.5
	if actual > 0 then
		local mul = max(0, actual + c) / actual
		return color.oklab(self.l, self.a * mul, self.b * mul, self.alpha)
	end
	return color.oklab(self.l, max(0, c), 0, self.alpha)
end

function color:withHue(h)
	local c = (self.a ^ 2 + self.b ^ 2) ^ 0.5
	return color.oklab(self.l, cos(h) * c, sin(h) * c, self.alpha)
end

function color:addedHue(h)
	local c = (self.a ^ 2 + self.b ^ 2) ^ 0.5
	h = atan(self.b, self.a) + h
	return color.oklab(self.l, cos(h) * c, sin(h) * c, self.alpha)
end

function color:withHueDegrees(h)
	return self:withHue(rad(h))
end

function color:addedHueDegrees(h)
	return self:addedHue(rad(h))
end

return color