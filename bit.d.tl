local record bit
	tobit: function(x: integer): integer
	tohex: function(x: integer, n: integer): string
	
	bnot: function(x: integer): integer
	bor: function(a: integer, ...: integer): integer
	band: function(a: integer, ...: integer): integer
	bxor: function(a: integer, ...: integer): integer
	
	lshift: function(x: integer, n: integer): integer
	rshift: function(x: integer, n: integer): integer
	arshift: function(x: integer, n: integer): integer
	rol: function(x: integer, n: integer): integer
	ror: function(x: integer, n: integer): integer
	
	bswap: function(x: integer): integer
end

return bit