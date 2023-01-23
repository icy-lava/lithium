local record common
	type Packed = record<T>
		{T}
		n: integer
	end
	
	noop: function(...: any)
	empty: {any:nil}
	isEmpty: function(t: table): boolean
	
	index: function(t: table, ...: any): any
	set: function(t: table, ...: any): any
	delete: function<K, V>(t: {K:V}, ...: any): {K:V}
	clear: function<K, V>(t: {K:V}): {K:V}
	
	pack: function<T>(...: T): Packed<T>
	packCaptures: function<T>(start: integer, stop: integer, ...: T): integer, integer, Packed<T>
	unpack: function<T>({T}, integer, integer): T...
	
	ripairs: function<T>({T}): function(): (integer, T), table, integer
	keys: function<K, V>({K:V}): function(): (K), {K:V}
	array: function<T>(function(...: any): (T, any...), ...: any): {T}
end

return common