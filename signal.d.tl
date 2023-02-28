local record Signal<T>
	type NoReturn = function(...: any): ()
	type Object = {T:function({T:any}, ...: any): ()}
	-- type ObjectEvent = function(Object, ...: any): ()
	type ObjectEvent = function({T:any}, ...: any): ()
	funcHooks: {NoReturn:boolean}
	objHooks: {Object:T}
	
	new: function(): Signal<T>
	connect: function<U>(self: Signal<U>, func: NoReturn)
	connect: function<U>(self: Signal<U>, event: U, obj: {U:function({U:any}, ...: any): ()})
	disconnect: function<U>(self: Signal<U>, funcOrObj: NoReturn | {U:function({U:any}, ...: any): ()})
	emit: function<U>(self: Signal<U>, ...: any)
end

return Signal