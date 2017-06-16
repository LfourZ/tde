function renderVector(vec, res)
	love.graphics.setColor(255,255,255,255)
	for k, v in ipairs(vec) do
		if v.color then
			love.graphics.setColor(v.color)
		end
		if v.shape == "rectangle" then
			if v.ry then v.ry = v.ry * res end
			if v.rx then v.rx = v.rx * res end
			love.graphics.rectangle(
				"fill",
				v.x * res,
				v.y * res,
				v.w * res,
				v.h * res)
		elseif v.shape == "circle" then
			love.graphics.circle(
				"fill",
				v.x * res,
				v.y * res,
				v.radius * res)
		elseif v.shape == "polygon" then
			local points = {}
			for k, v in ipairs(v.points) do
				points[k] = v * res
			end
			if #points >= 6 then
				love.graphics.polygon(
					"fill", 
					points)
			end
		elseif v.shape == "ellipse" then
			love.graphics.ellipse(
				"fill",
				v.x * res,
				v.y * res,
				v.radiusx * res,
				v.radiusy * res)
		elseif v.shape == "arc" then
			love.graphics.arc(
				"fill",
				v.arctype or "pie",
				v.x * res,
				v.y * res,
				v.radius,
				v.a1,
				v.a2)
		end
	end
end

function renderVectorToCanvas(vec, res)
	local canvas = love.graphics.newCanvas(res, res)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(255,255,255,255)
	for k, v in ipairs(vec) do
		if v.color then
			love.graphics.setColor(v.color)
		end
		if v.shape == "rectangle" then
			if v.ry then v.ry = v.ry * res end
			if v.rx then v.rx = v.rx * res end
			love.graphics.rectangle(
				"fill",
				v.x * res,
				v.y * res,
				v.w * res,
				v.h * res)
		elseif v.shape == "circle" then
			love.graphics.circle(
				"fill",
				v.x * res,
				v.y * res,
				v.radius * res)
		elseif v.shape == "polygon" then
			local points = {}
			for k, v in ipairs(v.points) do
				points[k] = v * res
			end
			if #points >= 6 then
				love.graphics.polygon(
					"fill", 
					points)
			end
		elseif v.shape == "ellipse" then
			love.graphics.ellipse(
				"fill",
				v.x * res,
				v.y * res,
				v.radiusx * res,
				v.radiusy * res)
		elseif v.shape == "arc" then
			love.graphics.arc(
				"fill",
				v.arctype or "pie",
				v.x * res,
				v.y * res,
				v.radius,
				v.a1,
				v.a2)
		end
	end
	love.graphics.setCanvas()
	return canvas
end

function renderGrid(scale, res)
	local step = res / scale
	local canvas = love.graphics.newCanvas(res, res)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(255,0,0)
	for i = 1, scale - 1 do
		love.graphics.line(step * i, 0, step * i, res)
		love.graphics.line(0, step * i, res, step * i)
	end
	love.graphics.setCanvas()
	return canvas
end

function round(num)
	if num % 1 < 0.5 then
		return math.floor(num)
	else
		return math.ceil(num)
	end
end

function clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

function getNearestGrid(x, y, scale, res)
	if scale == 0 then
		return x, y
	end
	x, y = clamp(x, 0, res), clamp(y, 0, res)
	local step  = res / scale
	return round(x / step) * step, round(y / step) * step
end

function firstEmptyKey(array)
	local len = #array
	if len == 0 then return 1	
	elseif len == 1 then return 2
	elseif array[len-1] == nil then return len - 1
	else return len + 1
	end
end

function wToS(num, res)
	return num / res
end

function getStep(scale, res)
	return res / scale
end

function distance (x1, y1, x2, y2)
  	local dx, dy = x1 - x2, y1 - y2
 	return math.sqrt(dx^2 + dy^2)
end