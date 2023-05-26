local record color
	oklab: function(l: number, a: number, b: number, alpha: number): color
	rgb: function(r: number, g: number, b: number, alpha: number): color
	
	lerp: function(self: color, t: number, other: color): color
	splitOklab: function(self: color): number, number, number, number
	splitRGB: function(self: color): number, number, number, number
	array: function(self: color): {number, number, number, number}
	withAlpha: function(self: color, alpha: number): color
	addedAlpha: function(self: color, alpha: number): color
	withLightness: function(self: color, lightness: number): color
	addedLightness: function(self: color, lightness: number): color
	withChroma: function(self: color, chroma: number): color
	addedChroma: function(self: color, chroma: number): color
	withHue: function(self: color, hue: number): color
	addedHue: function(self: color, hue: number): color
	withHueDegrees: function(self: color, hue: number): color
	addedHueDegrees: function(self: color, hue: number): color
end

return color