local record comb
	record State<Data, Result>
		source: string
		data: Data
		result: Result
		index: integer
	end

	record Error
		message: string
		index: integer
	end
	
	record Tag<T, R>
		tag: T
		value: R
	end
	
	record TagWithIndex<T, R>
		tag: T
		index: integer
		value: R
	end
	
	record Match
		match: string
		captures: {string}
	end
	
	record Binary<O, L, R>
		operator: O
		left: L
		right: R
	end

	record Parser<Data, ResultFrom, ResultTo>
		_transformer: function(State<Data, ResultFrom>): State<Data, ResultTo>, Error
		
		new: function<D, F, T>(function(State<D, F>): State<D, T>, Error): Parser<D, F, T>
		run: function<D, F, T>(self: Parser<D, F, T>, state: State<D, F>): State<D, T>, Error
		parseData: function<D, F, T>(self: Parser<D, F, T>, data: D, source: string): State<D, T>, string
		parseFile: function<D, F, T>(self: Parser<D, F, T>, data: D): State<D, T>, string
		
		map: function<D, F, T, NT>(self: Parser<D, F, T>, mapper: function(state: State<D, T>): State<D, NT>): Parser<D, F, NT>
		mapError: function<D, F, T>(self: Parser<D, F, T>, mapper: function(err: Error): Error): Parser<D, F, T>, Error
		chain: function<D, F, T, NT>(self: Parser<D, F, T>, resultToParser: function(result: T): Parser<D, T, NT>): Parser<D, F, NT>, Error
		
		noConsume: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, F>
		peek: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, T>
		atLeast: function<D, F, T>(self: Parser<D, F, T>, count: integer): Parser<D, F, {T}>
		atMost: function<D, F, T>(self: Parser<D, F, T>, count: integer): Parser<D, F, {T}>
		
		opposite: function<D, F, T>(self: Parser<D, F, T>, message: string): Parser<D, F, F>
		
		tag: function<D, F, T, TT>(self: Parser<D, F, T>, name: TT): Parser<D, F, Tag<TT, T>>
		tagWithIndex: function<D, F, T, TT>(self: Parser<D, F, T>, name: TT): Parser<D, F, TagWithIndex<TT, T>>
		
		delimited: function<D, F, T>(self: Parser<D, F | T, T>, delimiter: Parser<D, any, any>): Parser<D, F, {T}>
		delimited: function<D, R>(self: Parser<D, R, R>, delimiter: Parser<D, any, any>): Parser<D, R, {R}>
		delimited: function<D, R>(self: Parser<D, any, R>, delimiter: Parser<D, any, any>): Parser<D, any, {R}>
		enclosed: function<D, F, T>(self: Parser<D, F, T>, left: Parser<D, any, any>, right: Parser<D, any, any>): Parser<D, F, T>
		prefix: function<D, F, T>(self: Parser<D, F, T>, other: Parser<D, any, any>): Parser<D, F, T>
		suffix: function<D, F, T>(self: Parser<D, F, T>, other: Parser<D, any, any>): Parser<D, F, T>
		optional: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, T>
		
		wsl: function<F, T>(self: Parser<string, F, T>): Parser<string, F, T>
		wsr: function<F, T>(self: Parser<string, F, T>): Parser<string, F, T>
		wse: function<F, T>(self: Parser<string, F, T>): Parser<string, F, T>
		
		index: function<D, F, T>(self: Parser<D, F, {T}>, key: integer): Parser<D, F, T>
		index: function<D, F, K, V>(self: Parser<D, F, {K:V}>, key: K): Parser<D, F, V>
		first: function<D, F, T>(self: Parser<D, F, {T}>): Parser<D, F, T>
		second: function<D, F, T>(self: Parser<D, F, {T}>): Parser<D, F, T>
		third: function<D, F, T>(self: Parser<D, F, {T}>): Parser<D, F, T>
		last: function<D, F, T>(self: Parser<D, F, {T}>): Parser<D, F, T>
		
		match: function<R>(self: Parser<string, R, Match>): Parser<string, R, string>
		captures: function<R>(self: Parser<string, R, Match>): Parser<string, R, {string}>
		
		concat: function<D, F, T>(self: Parser<D, F, {T}>, sep: string): Parser<D, F, string>
		default: function<D, F, T>(self: Parser<D, F, T>, value: T): Parser<D, F, T>
		default: function<D, F, T, DV>(self: Parser<D, F, T>, value: DV): Parser<D, F, T | DV>
		value: function<D, F, T, V>(self: Parser<D, F, T>, value: V): Parser<D, F, V>
		null: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, nil>
		gsub: function(self: Parser<string, string, string>, pattern: string, repl: string, n: integer): Parser<string, string, string>
		
		metamethod __call: function<D, F, T>(self: Parser<D, F, T>, state: State<D, F>): State<D, T>, Error
		metamethod __add: function<D, F, T>(self: Parser<D, F, T>, other: Parser<D, F, T>): Parser<D, F, T>
		metamethod __add: function<D, F, T, O>(self: Parser<D, F, T>, other: Parser<D, F, O>): Parser<D, F, T | O>
		metamethod __sub: function<D, F, T, O>(self: Parser<D, F, T>, other: Parser<D, F, O>): Parser<D, F, T>
		metamethod __mul: function<D, F, T, O>(self: Parser<D, F, T>, other: Parser<D, T, O>): Parser<D, F, O>
		metamethod __div: function<D, F, T, NT>(self: Parser<D, F, T>, func: function(result: T): NT): Parser<D, F, NT>
		metamethod __mod: function<D, F, T>(self: Parser<D, F, T>, func: function(err: Error): Error): Parser<D, F, T>
		metamethod __len: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, F>
		metamethod __pow: function<D, F, T>(self: Parser<D, F, T>, exponent: integer): Parser<D, F, {T}>
		metamethod __unm: function<D, F, T>(self: Parser<D, F, T>): Parser<D, F, F>
	end
	
	isError: function(value: any): boolean
	error: function<D, R>(state: State<D, R>, message: string): Error
	
	literal: function(str: string): Parser<string, any, string>
	pattern: function(pat: string): Parser<string, any, Match>
	uptoLiteral: function(str: string): Parser<string, any, string>
	uptoPattern: function(pat: string): Parser<string, any, string>
	sequence: function<D, F, T>(parsers: {Parser<D, F | T, T>}): Parser<D, F, {T}>
	sequence: function<D, R>(parsers: {Parser<D, R, R>}): Parser<D, R, {R}>
	sequence: function<D, R>(parsers: {Parser<D, any, R>}): Parser<D, any, {R}>
	choice: function<D, F, T>(parsers: {Parser<D, F, T>}): Parser<D, F, T>
	choice: function<D, R>(parsers: {Parser<D, any, R>}): Parser<D, any, R>
	choice: function<D>(parsers: {Parser<D, any, any>}): Parser<D, any, any>
	proxy: function<D, F, T>(getParser: function(): Parser<D, F, T>): Parser<D, F, T>
	delimited: function<D, F, T>(delimiter: Parser<D, any, any>): function(Parser<D, F | T, T>): Parser<D, F, {T}>
	delimited: function<D, R>(delimiter: Parser<D, any, any>): function(Parser<D, R, R>): Parser<D, R, {R}>
	delimited: function<D, R>(delimiter: Parser<D, any, any>): function(Parser<D, any, R>): Parser<D, any, {R}>
	enclosed: function<D, F, T>(left: Parser<D, any, any>, right: Parser<D, any, any>): function(Parser<D, F, T>): Parser<D, F, T>
	
	-- Brain too small for this one
	-- binary: function<D, F, T, O>(parser: Parser<D, F | O, T>, precDef: {{Parser<D, T, O>}}): 
	
	u8: Parser<string, any, integer>
	i8: Parser<string, any, integer>
	u16le: Parser<string, any, integer>
	i16le: Parser<string, any, integer>
	u16be: Parser<string, any, integer>
	i16be: Parser<string, any, integer>
	u32le: Parser<string, any, integer>
	i32le: Parser<string, any, integer>
	u32be: Parser<string, any, integer>
	i32be: Parser<string, any, integer>
	
	digit: Parser<string, any, string>
	digits: Parser<string, any, string>
	letter: Parser<string, any, string>
	letters: Parser<string, any, string>
	
	whitespace: Parser<string, any, string>
	mws: Parser<string, any, string>
	cr: Parser<string, any, string>
	lf: Parser<string, any, string>
	crlf: Parser<string, any, string>
	newline: Parser<string, any, string>
	-- eof: Parser<string | {any}, any, any>
	eof: Parser<string, any, any>
	endline: Parser<string, any, any>
	identifier: Parser<string, any, string>
end

return comb