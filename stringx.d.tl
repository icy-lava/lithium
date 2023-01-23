local record stringx
	delim: function(str: string, delim: string, isPattern: boolean): function(): string
	lines: function(str: string): function(): string
	lineAt: function(str: string, i: integer, newlinePattern: string): integer
	positionAt: function(str: string, i: integer, newlinePattern: string): integer, integer
	split: function(str: string, delim: string, isPattern: boolean): {string}
	
	startsWith: function(str: string, prefix: string): boolean
	endsWiths: function(str: string, suffix: string): boolean
	contains: function(str: string, substr: string): boolean
	
	trimLeft: function(str: string): string
	trimRight: function(str: string): string
	trim: function(str: string): string
	trimNonEmpty: function(str: string): string
end

return stringx