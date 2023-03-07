local common = require 'lithium.common'

local record lstring
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
	delim        = lstring.delim,
	lines        = lstring.lines,
	lineAt       = lstring.lineAt,
	positionAt   = lstring.positionAt,
	split        = lstring.split,
	
	startsWith   = lstring.startsWith,
	endsWiths    = lstring.endsWiths,
	contains     = lstring.contains,
	
	trimLeft     = lstring.trimLeft,
	trimRight    = lstring.trimRight,
	trim         = lstring.trim,
	trimNonEmpty = lstring.trimNonEmpty,
}