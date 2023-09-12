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

local function oklch2oklab(L, c, h, alpha)
	return L, cos(h) * c, sin(h) * c, alpha
end

function color.oklab(l, a, b, alpha)
	assert(l and a and b)
	return color.oklch(oklab2oklch(l, a, b, alpha))
end

function color.oklch(l, c, h, alpha)
	assert(l and c and h)
	return setmetatable({l, c, rad(h), alpha or 1}, color)
end

function color.rgb(r, g, b, alpha)
	assert(r and g and b)
	return color.oklab(rgb2oklab(r, g, b, alpha or 1))
end

function color.fromLove()
	return color.rgb(love.graphics.getColor()) -- luacheck: ignore 113
end

function color.fromLoveBackground()
	return color.rgb(love.graphics.getBackgroundColor()) -- luacheck: ignore 113
end

function color:__tostring()
	return format(
		'oklch {lightness = %d%%, chroma = %0.2f, hue = %d deg, alpha = %d%%}',
		self.l * 100 + 0.5, self.c, deg(self.h) + 0.5, self.alpha * 100 + 0.5
	)
end

function color:lerp(t, other)
	local l1, a1, b1, alpha1 = oklch2oklab(self[1], self[2], self[3], self[4])
	local l2, a2, b2, alpha2 = oklch2oklab(other[1], other[2], other[3], other[4])
	local m = 1 - t
	return color.oklab(
		l1 * m + l2 * t,
		a1 * m + a2 * t,
		b1 * m + b2 * t,
		alpha1 * m + alpha2 * t
	)
end

function color:splitOklab()
	return oklch2oklab(self[1], self[2], self[3], self[4])
end

function color:splitOklch()
	return self[1], self[2], self[3], self[4]
end

function color:splitRGB()
	return oklab2rgb(oklch2oklab(self[1], self[2], self[3], self[4]))
end

function color:array()
	return {self:splitRGB()}
end

function color:withAlpha(alpha)
	return color.oklch(self[1], self[2], self[3], alpha)
end

function color:addedAlpha(alpha)
	return color.oklch(self[1], self[2], self[3], max(0, self[4] + alpha))
end

function color:addmulAlpha(add, mul)
	add, mul = (add or 0), (mul or 1)
	return color.oklch(self[1], self[2], self[3], max(0, self[4] * mul + add))
end

function color:withLightness(lightness)
	return color.oklch(lightness, self[2], self[3], self[4])
end

function color:addedLightness(lightness)
	return color.oklch(max(0, self[1] + lightness), self[2], self[3], self[4])
end

function color:addmulLightness(add, mul)
	add, mul = (add or 0), (mul or 1)
	return color.oklch(max(0, self[1] * mul + add), self[2], self[3], self[4])
end

function color:withChroma(c)
	return color.oklch(self[1], c, self[3], self[4])
end

function color:addedChroma(c)
	return color.oklch(self[1], max(0, self[2] + c), self[3], self[4])
end

function color:addmulChroma(add, mul)
	add, mul = (add or 0), (mul or 1)
	return color.oklch(self[1], max(0, self[2] * mul + add), self[3], self[4])
end

function color:withHue(h)
	return color.oklch(self[1], self[2], rad(h), self[4])
end

function color:addedHue(h)
	return color.oklch(self[1], self[2], self[3] + rad(h), self[4])
end

function color:withHueRadians(h)
	return color.oklch(self[1], self[2], h, self[4])
end

function color:addedHueRadians(h)
	return color.oklch(self[1], self[2], self[3] + h, self[4])
end

function color:love()
	love.graphics.setColor(self:splitRGB()) -- luacheck: ignore 113
end

function color:loveBackground()
	love.graphics.setBackgroundColor(self:splitRGB()) -- luacheck: ignore 113
end

function color:loveClear()
	love.graphics.clear(self:splitRGB()) -- luacheck: ignore 113
end

return color