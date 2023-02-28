local common = require 'lithium.common'

local record tablex
	copy: function<K, V>(t: {K:V}): ({K:V})
	icopy: function<T>(t: {T}): ({T})
	clone: function<T>(t: T): (T)
	invert: function<K, V>(t: {K:V}): ({V:K})
	
	merge: function(...: table): (table)
	imerge: function(...: {any}): ({any})
	map: function<A, K, V, M>(t: {K:V}, function(value: V, ...: A): (M), ...: A): ({K:M})
	imap: function<A, V, M>(t: {V}, function(value: V, ...: A): (M), ...: A): ({M})
	filter: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): ({K:V})
	ifilter: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): ({V})
	reject: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): ({K:V})
	ireject: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): ({V})
	sort: function<T>(t: {T}, comp: any): ({T})
	reverse: function<T>(t: {T}): ({T})
	
	reduce: function<T>(t: {T}, reducer: function(a: T, b: T): (T)): (T)
	new: function(narr: integer, nrec: integer): (table)
end

return {
	-- table.*
	concat  = table.concat,
	insert  = table.insert,
	move    = table.move,
	remove  = table.remove,
	-- maxn    = table.maxn,
	-- sort    = table.sort,
	-- pack    = table.pack,
	-- unpack  = table.unpack,
	
	-- lithium.common
	pack    = common.pack,
	unpack  = common.unpack,
	isEmpty = common.isEmpty,
	index   = common.index,
	set     = common.set,
	delete  = common.delete,
	clear   = common.clear,
	ripairs = common.ripairs,
	keys    = common.keys,
	array   = common.array,
	empty   = common.empty,
	
	-- lithium.tablex.*
	copy    = tablex.copy,
	icopy   = tablex.icopy,
	clone   = tablex.clone,
	invert  = tablex.invert,

	merge   = tablex.merge,
	imerge  = tablex.imerge,
	map     = tablex.map,
	imap    = tablex.imap,
	filter  = tablex.filter,
	ifilter = tablex.ifilter,
	reject  = tablex.reject,
	ireject = tablex.ireject,
	sort    = tablex.sort,
	reverse = tablex.reverse,

	reduce  = tablex.reduce,
	new     = tablex.new,
}