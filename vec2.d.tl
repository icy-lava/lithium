local record vec2
	{number}
	
	length: number
	length2: number
	normal: vec2
	copy: vec2
	
	new: function(x: number, y: number): vec2
	fromPolar: function(angle: number, length: number): vec2
	fromLove: function(): vec2
	metamethod __call: function(self: vec2, x: number, y: number): vec2
	
	metamethod __add: function(self: vec2, other: vec2): vec2
	metamethod __sub: function(self: vec2, other: vec2): vec2
	metamethod __mul: function(self: vec2 | number, other: vec2 | number): vec2
	metamethod __div: function(self: vec2, other: vec2 | number): vec2
	metamethod __mod: function(self: vec2, other: vec2 | number): vec2
	metamethod __pow: function(self: vec2, other: vec2 | number): vec2
	metamethod __unm: function(self: vec2): vec2
	metamethod __eq: function(self: vec2, other: vec2): boolean
	metamethod __lt: function(self: vec2, other: vec2): boolean
	metamethod __le: function(self: vec2, other: vec2): boolean
	metamethod __tostring: function(self: vec2): string
	
	set: function(self: vec2, x: number, y: number)
	set: function(self: vec2, point: vec2)
	
	dot: function(self: vec2, other: vec2): number
	cross: function(self: vec2, other: vec2): number
	dist: function(self: vec2, other: vec2): number
	dist2: function(self: vec2, other: vec2): number
	delta: function(self: vec2, other: vec2): vec2
	lerp: function(self: vec2, t: number, other: vec2): vec2
	split: function(self: vec2): number, number
	perp: function(self: vec2): vec2
	polar: function(self: vec2): number, number
	rotate: function(self: vec2, delta: number)
	rotated: function(self: vec2, delta: number): vec2
	
	toLove: function(self: vec2)
	getAngle: function(self: vec2): number
	setAngle: function(self: vec2, angle: number)
	getLength: function(self: vec2): number
	setLength: function(self: vec2, length: number)
	getLength2: function(self: vec2): number
	setLength2: function(self: vec2, length2: number)
	getNormal: function(self: vec2): vec2
	getCopy: function(self: vec2): vec2
end

return vec2