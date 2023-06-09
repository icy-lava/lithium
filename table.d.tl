local common = require 'lithium.common'

local record ltable
	copy: function<K, V>(t: {K:V}): {K:V}
	icopy: function<T>(t: {T}): {T}
	clone: function<K, V>(t: {K:V}): {K:V}
	invert: function<V>(t: {V}): {V:integer}
	invert: function<K, V>(t: {K:V}): {V:K}
	
	find: function<K, V>(t: {K:V}, value: V): K
	ifind: function<V>(t: {V}, value: V): integer
	count: function<K, V>(t: {K:V}, value: V): integer
	countKeys: function<K, V>(t: {K:V}, key: K): integer
	icount: function<V>(t: {V}, value: V): integer
	
	mergeInto: function<K, V>(dest: {K:V}, ...: {K:V}): {K:V}
	mergeInto: function(dest: table, ...: table): table
	
	imergeInto: function<A>(dest: {A}, ...: {A}): {A}
	imergeInto: function(dest: {any}, ...: {any}): {any}
	
	merge: function<K, V>(...: {K:V}): {K:V}
	merge: function<K>(...: {K:string}): {K:string}
	merge: function<V>(...: {string:V}): {string:V}
	merge: function(...: {string:string}): {string:string}
	merge: function(...: table): table
	
	imerge: function<A>(...: {A}): {A}
	imerge: function(...: {string}): {string}
	imerge: function(...: {any}): {any}
	
	flatten: function<K, V>(t: {{K:V}}): {K:V}
	flatten: function<K>(t: {{K:string}}): {K:string}
	flatten: function<V>(t: {{string:V}}): {string:V}
	flatten: function(t: {{string:string}}): {string:string}
	flatten: function(t: {table}): table
	
	iflatten: function<A>(t: {{A}}): {A}
	iflatten: function<A>(t: {{string}}): {string}
	iflatten: function<A>(t: {{any}}): {any}
	
	reverse: function<T>(t: {T}, count: integer): {T}
	push: function<T>(t: {T}, ...: T): {T}
	
	map: function<A, K, V, M>(t: {K:V}, function(value: V, ...: A): (M), ...: A): {K:M}
	imap: function<A, V, M>(t: {V}, function(value: V, ...: A): (M), ...: A): {M}
	filter: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): {K:V}
	ifilter: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): {V}
	reject: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): {K:V}
	ireject: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): {V}
	sub: function(t: {integer}, i: integer, j: integer): {integer}
	sub: function(t: {number}, i: integer, j: integer): {number}
	sub: function<V>(t: {V}, i: integer, j: integer): {V}
	
	each: function<K, V>(t: {K:V}, function(key: K, value: V): boolean)
	ieach: function<V>(t: {V}, function(i: integer, value: V): boolean)
	sort: function<T>(t: {T}, comp: function(a: T, b: T): (boolean))
	sort: function<K, V>(t: {{K:V}}, comp: K)
	spairs: function<K, V>(t: {K:V}, comp: function(a: {K, V}, b: {K, V}): boolean): function(): K, V
	
	reduce: function(t: {integer}, reducer: function(a: integer, b: integer): (integer)): integer
	reduce: function(t: {number}, reducer: function(a: number, b: number): (number)): number
	reduce: function<T>(t: {T}, reducer: function(a: T, b: T): (T)): T
	new: function(narr: integer, nrec: integer): table
	new: function<K, V>(narr: integer, nrec: integer): {K:V}
end

return {
	-- table.*
	concat  = table.concat,
	insert  = table.insert,
	remove  = table.remove,
	-- move    = table.move,
	-- maxn    = table.maxn,
	-- sort    = table.sort,
	-- pack    = table.pack,
	-- unpack  = table.unpack,
	
	-- lithium.common
	empty      = common.empty,
	isEmpty    = common.isEmpty,
	array      = common.array,
	array2     = common.array2,
	get        = common.get,
	set        = common.set,
	delete     = common.delete,
	clear      = common.clear,
	pack       = common.pack,
	unpack     = common.unpack,
	ripairs    = common.ripairs,
	keys       = common.keys,
	values     = common.values,
	toPacked   = common.toPacked,
	toUnpacked = common.toUnpacked,
	sub        = common.sub,
	
	-- lithium.table.*
	copy    = ltable.copy,
	icopy   = ltable.icopy,
	clone   = ltable.clone,
	invert  = ltable.invert,
	
	find    = ltable.find,
	ifind   = ltable.ifind,
	
	count     = ltable.count,
	countKeys = ltable.countKeys,
	icount    = ltable.icount,

	mergeInto  = ltable.mergeInto,
	imergeInto = ltable.imergeInto,
	
	merge   = ltable.merge,
	imerge  = ltable.imerge,
	
	flatten  = ltable.flatten,
	iflatten = ltable.iflatten,
	
	reverse = ltable.reverse,
	push    = ltable.push,
	map     = ltable.map,
	imap    = ltable.imap,
	filter  = ltable.filter,
	ifilter = ltable.ifilter,
	reject  = ltable.reject,
	ireject = ltable.ireject,
	
	each    = ltable.each,
	ieach   = ltable.ieach,
	sort    = ltable.sort,
	spairs  = ltable.spairs,

	reduce  = ltable.reduce,
	new     = ltable.new,
}