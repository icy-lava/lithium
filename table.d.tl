local common = require 'lithium.common'

local record ltable
	copy: function<K, V>(t: {K:V}): {K:V}
	icopy: function<T>(t: {T}): {T}
	clone: function<K, V>(t: {K:V}): {K:V}
	invert: function<K, V>(t: {K:V}): {V:K}
	
	merge: function<K, V>(...: {K:V}): {K:V}
	merge: function<K1, K2, V1, V2>(t1: {K1:V1}, t2: {K2:V2}): {K1 | K2:V1 | V2}
	merge: function<K1, K2, K3, V1, V2, V3>(t1: {K1:V1}, t2: {K2:V2}, t3: {K3:V3}): {K1 | K2 | V3:V1 | V2 | V3}
	merge: function(...: table): table
	
	imerge: function<A>(...: {A}): {A}
	imerge: function<A, B>(t1: {A}, t2: {B}): {A | B}
	imerge: function<A, B, C>(t1: {A}, t2: {B}, t3: {C}): {A | B | C}
	imerge: function(...: {any}): {any}
	
	map: function<A, K, V, M>(t: {K:V}, function(value: V, ...: A): (M), ...: A): {K:M}
	imap: function<A, V, M>(t: {V}, function(value: V, ...: A): (M), ...: A): {M}
	filter: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): {K:V}
	ifilter: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): {V}
	reject: function<A, K, V>(t: {K:V}, function(value: V, ...: A): (boolean), ...: A): {K:V}
	ireject: function<A, V>(t: {V}, function(value: V, ...: A): (boolean), ...: A): {V}
	sort: function<T>(t: {T}, comp: function(a: T, b: T): (boolean))
	sort: function<K, V>(t: {{K:V}}, comp: K)
	reverse: function<T>(t: {T}): {T}
	
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
	move    = table.move,
	remove  = table.remove,
	-- maxn    = table.maxn,
	-- sort    = table.sort,
	-- pack    = table.pack,
	-- unpack  = table.unpack,
	
	-- lithium.common
	empty   = common.empty,
	isEmpty = common.isEmpty,
	array   = common.array,
	array2  = common.array2,
	index   = common.index,
	set     = common.set,
	delete  = common.delete,
	clear   = common.clear,
	pack    = common.pack,
	unpack  = common.unpack,
	ripairs = common.ripairs,
	keys    = common.keys,
	
	-- lithium.table.*
	copy    = ltable.copy,
	icopy   = ltable.icopy,
	clone   = ltable.clone,
	invert  = ltable.invert,

	merge   = ltable.merge,
	imerge  = ltable.imerge,
	map     = ltable.map,
	imap    = ltable.imap,
	filter  = ltable.filter,
	ifilter = ltable.ifilter,
	reject  = ltable.reject,
	ireject = ltable.ireject,
	sort    = ltable.sort,
	reverse = ltable.reverse,

	reduce  = ltable.reduce,
	new     = ltable.new,
}