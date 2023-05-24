local record color
	oklab: function(l: number, a: number, b: number, alpha: number): color
	rgb: function(r: number, g: number, b: number, alpha: number): color
	
	lerp: function(self: color, t: number, other: color): color
	splitOklab: function(self: color): number, number, number, number
	splitRGB: function(self: color): number, number, number, number
	array: function(self: color): {number, number, number, number}
	withAlpha: function(alpha: number): color
	addedAlpha: function(alpha: number): color
	withLightness: function(lightness: number): color
	addedLightness: function(lightness: number): color
	withChroma: function(chroma: number): color
	addedChroma: function(chroma: number): color
	withHue: function(hue: number): color
	addedHue: function(hue: number): color
	withHueDegrees: function(hue: number): color
	addedHueDegrees: function(hue: number): color
end

return color