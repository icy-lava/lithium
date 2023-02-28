local record mathx
	tau: number
	
	lerp: function<T>(t: number, a: number, b: number): number
	lerp: function<T>(t: number, a: T, b: T): T
	damp: function<T>(smoothing: number, dt: number, a: number, b: number): number
	damp: function<T>(smoothing: number, dt: number, a: T, b: T): T
	root: function(x: number): number
	cbrt: function(): number
	ternary: function(condition: boolean, ifTrue: integer, ifFalse: integer): integer
	ternary: function(condition: boolean, ifTrue: number, ifFalse: number): number
	ternary: function<A>(condition: boolean, ifTrue: A, ifFalse: A): A
	ternary: function<T, F>(condition: boolean, ifTrue: T, ifFalse: F): T | F
	isnan: function(x: number): boolean
	sign: function(x: number): integer
	clamp: function(value: integer, vmin: integer, vmax: integer): integer
	clamp: function(value: number, vmin: number, vmax: number): number
	wrap: function(value: integer, vmin: integer, vmax: integer): integer
	wrap: function(value: number, vmin: number, vmax: number): number
	map: function(value: number, fromMin: number, fromMax: number, toMin: number, toMax: number): number
	round: function(x: number): integer
	roundStep: function(x: number, step: integer): integer
	roundStep: function(x: number, step: number): number
end

return {
	-- math.*
	abs        = math.abs,
	acos       = math.acos,
	asin       = math.asin,
	atan       = math.atan,
	atan2      = math.atan2,
	ceil       = math.ceil,
	cos        = math.cos,
	cosh       = math.cosh,
	deg        = math.deg,
	exp        = math.exp,
	floor      = math.floor,
	fmod       = math.fmod,
	frexp      = math.frexp,
	huge       = math.huge,
	ldexp      = math.ldexp,
	log        = math.log,
	log10      = math.log10,
	max        = math.max,
	min        = math.min,
	modf       = math.modf,
	pi         = math.pi,
	pow        = math.pow,
	rad        = math.rad,
	random     = math.random,
	randomseed = math.randomseed,
	sin        = math.sin,
	sinh       = math.sinh,
	sqrt       = math.sqrt,
	tan        = math.tan,
	tanh       = math.tanh,
	
	-- lithium.mathx.*
	tau       = mathx.tau,
	lerp      = mathx.lerp,
	root      = mathx.root,
	cbrt      = mathx.cbrt,
	ternary   = mathx.ternary,
	isnan     = mathx.isnan,
	sign      = mathx.sign,
	clamp     = mathx.clamp,
	wrap      = mathx.wrap,
	map       = mathx.map,
	round     = mathx.round,
	roundStep = mathx.roundStep,
}