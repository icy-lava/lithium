local record common
	type Packed = record<T>
		{T}
		n: integer
	end
	
	noop: function(...: any)
	pass: function<T>(...: T): T...
	pass: function<T>(...: any): any...
	empty: {any:nil}
	isEmpty: function(t: table): boolean
	
	array: function<T>(function(...: any): (T, any...), ...: any): {T}
	array2: function<A, B>(function(...: any): (A, B, any...), ...: any): {{A, B}}
	
	get: function<K, V>(t: {K:V}, k: K): V
	get: function<K1, K2, V>(t: {K1:{K2:V}}, k1: K1, k2: K2): V
	get: function<K1, K2, K3, V>(t: {K1:{K2:{K3:V}}}, k1: K1, k2: K2, k3: K3): V
	get: function(t: table, ...: any): any
	
	set: function<V>(t: table, v: V): V
	set: function<K, V>(t: {K:V}, k: K, v: V): {K:V}
	set: function<K1, K2, V>(t: {K1:{K2:V}}, k1: K1, k2: K2, v: V): {K1:{K2:V}}
	set: function<K1, K2, K3, V>(t: {K1:{K2:{K3:V}}}, k1: K1, k2: K2, k3: K3, v: V): {K1:{K2:{K3:V}}}
	set: function<K1, K2>(t: {K1:any}, k1: K1, k2: K2, ...: any): {K1:any}
	
	delete: function<K, V>(t: {K:V}, ...: any): {K:V}
	clear: function<K, V>(t: {K:V}): {K:V}
	
	pack: function(...: integer): Packed<integer>
	pack: function(...: number): Packed<number>
	pack: function<A>(...: A): Packed<A>
	packCaptures: function(start: integer, stop: integer, ...: integer): integer, integer, Packed<integer>
	packCaptures: function(start: integer, stop: integer, ...: number): integer, integer, Packed<number>
	packCaptures: function<T>(start: integer, stop: integer, ...: T): integer, integer, Packed<T>
	unpack: function<T>({T}, integer, integer): T...
	
	ripairs: function<T>({T}): function(): (integer, T), {T}, integer
	keys: function<K>({K:any}): {K}
	
	quote: function(a: any): string
	quote: function(a: any, b: any): string, string
	quote: function(a: any, b: any, c: any): string, string, string
	quote: function(...: any): string...
	
	pretty: function(a: any): string
	pretty: function(a: any, b: any): string, string
	pretty: function(a: any, b: any, c: any): string, string, string
	pretty: function(...: any): string...
	
	fpprint: function(file: FILE, ...: any)
	pprint: function(...: any)
	epprint: function(...: any)
	
	readFile: function(path: string, bytes: integer): string, string
	writeFile: function(path: string, str: string): boolean, string
	appendFile: function(path: string, str: string): boolean, string
	fileLines: function(path: string): function(): string
	
	isWindows: boolean
	formCommand: function(program: string, ...: string): string
	execute: function(program: string, ...: string): integer
	
	readProcess: function(program: string, ...: string): string, string
	writeProcess: function(data: string, program: string, ...: string): boolean, string
	processLines: function(command: string): function(): string
	
	readCommand: function(command: string): string, string
	writeCommand: function(data:string, command: string): boolean, string
	commandLines: function(command: string): function(): string
end
-- local file: FILE
-- file:lines
return common