function firstEmptyKey(array)
	local len = #array
	if len == 0 then return 1	
	elseif len == 1 then return 2
	elseif array[len-1] == nil then return len - 1
	else return len + 1
	end
end

function pDistance(x, y, x1, y1, x2, y2)
	local dx1, dy1, dx2, dy2 = x - x1, y - y1, x2 - x1, y2 - y1
	local dot = dx1 * dx2 + dy1 * dy2
	local len_sq = dx2 * dx2 + dy2 * dy2
	local param = -1
	if len_sq ~= 0 then --in case of 0 length line
		param = dot / len_sq
	end
	local xx, yy
	if param < 0 then
		xx, yy = x1, y1
	elseif param > 1 then
		xx, yy = x2, y2
	else
		xx, yy = x1 + param * dx2, y1 + param * dy2
	end
	local dx, dy = x - xx, y - yy
	return math.sqrt(dx * dx + dy * dy)
end

function onPath(entity)
	for i = 1, #_G.curmap.path - 1 do
		if pDistance(entity.x, entity.y, 
			_G.curmap.path[i][1], 
			_G.curmap.path[i][2], 
			_G.curmap.path[i+1][1], 
			_G.curmap.path[i+1][2]) < 
			entity.radius + (_G.curmap.path[i][3] or _G.curmap.pathwidth) then
			return true
		end
	end
	return false
end

function distance (x1, y1, x2, y2)
  	local dx, dy = x1 - x2, y1 - y2
 	return math.sqrt(dx^2 + dy^2)
end

function overlapping(x1, y1, x2, y2, r1, r2)
	return distance(x1, y1, x2, y2) < r1 + r2
end

function renderVector(vector, res, msaa)
	local canvas = love.graphics.newCanvas(res, res, nil, msaa)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(255,255,255,255)
	for k, v in ipairs(vector) do
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
				v.radius * res,
				v.segments)
		elseif v.shape == "polygon" then
			local points = {}
			for k, v in ipairs(v.points) do
				points[k] = v * res
			end
			love.graphics.polygon(
				"fill", 
				points)
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
	love.graphics.setColor(255,255,255)
	love.graphics.setCanvas()
	return canvas
end