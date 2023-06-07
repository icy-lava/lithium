local record buffer
	record Options
		dict: {string}
		metatable: {table}
	end
	
	new: function(size: integer, options: Options): buffer
	new: function(options: Options): buffer
	
	reset: function(self: buffer): buffer
	free: function(self: buffer): buffer
	
	put: function(self: buffer, ...: any): buffer
	putf: function(self: buffer, format: string, ...: any): buffer
	putcdata: function(self: buffer, cdata: any, len: integer): buffer
	set: function(self: buffer, str: string): buffer
	set: function(self: buffer, cdata: any, len: integer): buffer
	reserve: function(self: buffer, used: integer): buffer
	reserve: function(self: buffer, size: integer): any, integer
	
	metamethod __len: function(t: buffer): integer
	metamethod __concat: function(t: buffer, other: any): string
	
	skip: function(self: buffer, len: integer): buffer
	get: function(self: buffer, ...: integer | nil): string, string...
	tostring: function(self: buffer): string
	ref: function(self: buffer): any, integer
	
	encode: function(self: buffer, obj: table): buffer
	encode: function(obj: table): string
	decode: function(str: string): table
	decode: function(self: buffer): table
end

return buffer