local record color
	oklab: function(l: number, a: number, b: number, alpha: number): color
	oklch: function(l: number, c: number, h: number, alpha: number): color
	rgb: function(r: number, g: number, b: number, alpha: number): color
	fromLove: function(): color
	fromLoveBackground: function(): color
	
	lerp: function(self: color, t: number, other: color): color
	splitOklab: function(self: color): number, number, number, number
	splitRGB: function(self: color): number, number, number, number
	array: function(self: color): {number, number, number, number}
	withAlpha: function(self: color, alpha: number): color
	addedAlpha: function(self: color, alpha: number): color
	addmulAlpha: function(self: color, add: number, mul: number): color
	withLightness: function(self: color, lightness: number): color
	addedLightness: function(self: color, lightness: number): color
	addmulLightness: function(self: color, add: number, mul: number): color
	withChroma: function(self: color, chroma: number): color
	addedChroma: function(self: color, chroma: number): color
	addmulChroma: function(self: color, add: number, mul: number): color
	withHue: function(self: color, hue: number): color
	addedHue: function(self: color, hue: number): color
	withHueDegrees: function(self: color, hue: number): color
	addedHueDegrees: function(self: color, hue: number): color
	love: function(self: color)
	loveBackground: function(self: color)
	loveClear: function(self: color)
end

return color