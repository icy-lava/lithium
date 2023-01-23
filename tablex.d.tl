local common = require 'lithium.common'

return {
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
	
	copy = nil as function<K, V>(t: {K:V}): ({K:V}),
	icopy = nil as function<T>(t: {T}): ({T}),
	clone = nil as function<T>(t: T): (T),
	invert = nil as function<K, V>(t: {K:V}): ({V:K}),
	
	merge = nil as function(...: table): (table),
	imerge = nil as function(...: {any}): ({any}),
	map = nil as function<A, K, V, M>(t: {K:V}, function(value: V, ...: A): (M), ...: A): ({K:M}),
	imap = nil as function<A, V, M>(t: {V}, function(value: V, ...: A): (M), ...: A): ({M}),
	filter = nil as function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): ({K:V}),
	ifilter = nil as function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): ({V}),
	reject = nil as function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): ({K:V}),
	ireject = nil as function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): ({V}),
	sort = nil as function<T>(t: {T}, comp: any): ({T}),
	reverse = nil as function<T>(t: {T}): ({T}),
	
	reduce = nil as function<T>(t: {T}, reducer: function(a: T, b: T): (T)): (T),
	new = nil as function(narr: integer, nrec: integer): (table),
}