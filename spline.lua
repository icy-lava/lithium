local unpack = table.unpack or unpack -- luacheck: ignore 143
local spline = {}

-- linear bezier
function spline.lbezier(t, a, b)
	return a * (1 - t) + b * t
end

-- quadratic bezier
function spline.qbezier(t, a, b, c)
	local t2 = t ^ 2
	return a * (1 - 2 * t + t2) +
		b * (2 * t - 2 * t2) +
		c * t2
end

-- cubic bezier
function spline.cbezier(t, a, b, c, d)
	local t2 = t ^ 2
	local t3 = t2 * t
	return a * (1 - t3 + 3 * t2 - 3 * t) +
		b * (3 * t3 - 6 * t2 + 3 * t) +
		c * (-3 * t3 + 3 * t2) +
		d * t3
end

-- generic bezier (nth degreee)
function spline.bezier(t, points)
	local count = #points
	assert(count >= 2)
	
	-- first try any known ones
	if count == 4 then
		return spline.cbezier(t, points[1], points[2], points[3], points[4])
	elseif count == 3 then
		return spline.qbezier(t, points[1], points[2], points[3])
	elseif count == 2 then
		return spline.lbezier(t, points[1], points[2])
	end
	
	-- use generic implementation
	local newPoints = {}
	local start, stop = nil, points[1] -- luacheck: ignore 311
	for i = 1, count - 1 do
		start, stop = stop, points[i + 1]
		newPoints[i] = spline.lbezier(t, start, stop)
	end
	
	return spline.bezier(t, newPoints)
end

function spline.render(count, points, splineFunc)
	if count == 1 then
		return {splineFunc(0.5, points)}
	end
	local to = count - 1
	local newPoints = {}
	for i = 0, to do
		local t = i / to
		newPoints[i + 1] = splineFunc(t, points)
	end
	return newPoints
end

return spline