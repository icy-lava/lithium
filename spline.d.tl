local record spline
	lerp: function<T>(t: number, start: T, stop: T): T
	qbezier: function<T>(t: number, start: T, control: T, stop: T): T
	cbezier: function<T>(t: number, start: T, control1: T, control2: T, stop: T): T
	bezier: function<T>(t: number, ...: T): T
	render: function<T>(count: integer, points: {T}, splineFunc: function(t: number, points: {T}): (T)): {T}
end

return spline