local common = require 'lithium.common'

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

return {
	-- string.*
	find    = string.find,
	format  = string.format,
	rep     = string.rep,
	gsub    = string.gsub,
	len     = string.len,
	gmatch  = string.gmatch,
	dump    = string.dump,
	match   = string.match,
	reverse = string.reverse,
	byte    = string.byte,
	char    = string.char,
	upper   = string.upper,
	lower   = string.lower,
	sub     = string.sub,
	
	-- lithium.common
	quote = common.quote,
	pretty = common.pretty,
	pprint = common.pprint,
	
	-- lithium.string.*
	delim        = stringx.delim,
	lines        = stringx.lines,
	lineAt       = stringx.lineAt,
	positionAt   = stringx.positionAt,
	split        = stringx.split,
	
	startsWith   = stringx.startsWith,
	endsWiths    = stringx.endsWiths,
	contains     = stringx.contains,
	
	trimLeft     = stringx.trimLeft,
	trimRight    = stringx.trimRight,
	trim         = stringx.trim,
	trimNonEmpty = stringx.trimNonEmpty,
}