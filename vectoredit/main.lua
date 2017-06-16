love.window.setMode(788, 512, {})
require("serial")
require("functions")
local suit = require("suit")

local gamera = require("gamera")
local camera = gamera.new(0,0,512,512)
camera:setWindow(0,0,512,512)
local res = 512
local MODE = "vedit"
--GLOBAL
if MODE == "vedit" then
	local vector = require("vector")
	local px, py
	local gridSize = 4
	local grid = renderGrid(gridSize, res)
	love.graphics.setBackgroundColor(128,128,128)

	local selected
	local scroll = 0

	local filename = {text="placeholder"}
	function love.draw()
		camera:draw(function(x,y,w,h)
			renderVector(vector.icon, 512)
			love.graphics.setColor(255,255,255)
			love.graphics.draw(grid)
			love.graphics.setColor(0,0,0,255)
			love.graphics.line(256,0,256,512)
			love.graphics.line(0,256,512,256)
		end)
		local mx, my = love.mouse.getPosition()
		if mx <= res and my <= res then
			local rx, ry = getNearestGrid(mx, my, gridSize, res)
			love.graphics.setColor(0,255,0)
			love.graphics.circle("fill", rx, ry, 5)
		end
		if px and py then
			love.graphics.setColor(0,0,255)
			love.graphics.circle("fill", px, py, 5)
		end
		suit.draw()
	end

	local _r = {value=0,min=0,max=255}
	local _g = {value=0,min=0,max=255}
	local _b = {value=0,min=0,max=255}
	local _a = {value=0,min=0,max=255}

	local _rt = {text=tostring(_r.value)}
	local _gt = {text=tostring(_g.value)}
	local _bt = {text=tostring(_b.value)}
	local _at = {text=tostring(_a.value)}

	local _rs = 0
	local _gs = 0
	local _bs = 0
	local _as = 0

	local menu = "main"
	local selectedShape

	local slider = {value=128,min=0,max=255}
	function love.update(Dt)
		suit.layout:reset(522, 10 + scroll)
		suit.layout:padding(10,10)
		if selected then
			--RED
			suit.Label("Red", suit.layout:row(256,20))
			if suit.Slider(_r, suit.layout:row(256,20)).changed then
				selected.color[1] = _r.value
				_rt.text = tostring(_r.value)
			end
			if suit.Input(_rt, suit.layout:row(256,10)).submitted then
				if tonumber(_rt.text) ~= nil then
					_r.value = clamp(_rt.text, 0, 255)
					_rt.text = tostring(_r.value)
					selected.color[1] = _r.value
				end
			end
			--GREEN
			suit.Label("Green", suit.layout:row(256,20))
			if suit.Slider(_g, suit.layout:row(256,20)).changed then
				selected.color[2] = _g.value
				_gt.text = tostring(_g.value)
			end
			if suit.Input(_gt, suit.layout:row(256,10)).submitted then
				if tonumber(_gt.text) ~= nil then
					_g.value = clamp(_gt.text, 0, 255)
					_gt.text = tostring(_g.value)
					selected.color[2] = _g.value
				end
			end
			--BLUE
			suit.Label("Blue", suit.layout:row(256,20))
			if suit.Slider(_b, suit.layout:row(256,20)).changed then
				selected.color[3] = _b.value
				_bt.text = tostring(_b.value)
			end
			if suit.Input(_bt, suit.layout:row(256,10)).submitted then
				if tonumber(_bt.text) ~= nil then
					_b.value = clamp(_bt.text, 0, 255)
					_bt.text = tostring(_b.value)
					selected.color[3] = _b.value
				end
			end
			--ALHPA
			suit.Label("Alpha", suit.layout:row(256,20))
			if suit.Slider(_a, suit.layout:row(256,20)).changed then
				selected.color[4] = _a.value
				_at.text = tostring(_a.value)
			end
			if suit.Input(_at, suit.layout:row(256,10)).submitted then
				if tonumber(_at.text) ~= nil then
					_a.value = clamp(_at.text, 0, 255)
					_at.text = tostring(_a.value)
					selected.color[4] = _a.value
				end
			end
			--
			if selected.id ~= 1 then
				if suit.Button("Move up", suit.layout:row(256,20)).hit then
					local selid = selected.id
					local buffer = vector.icon[selid-1]
					vector.icon[selid-1] = selected
					vector.icon[selid-1].id = selid - 1
					vector.icon[selid] = buffer
					vector.icon[selid].id = selid + 1
				end
			end
			if selected.id ~= #vector.icon then
				if suit.Button("Move down", suit.layout:row(256,20)).hit then
					local selid = selected.id
					local buffer = vector[selid+1]
					vector.icon[selid+1] = selected
					vector.icon[selid+1].id = selid + 1
					vector.icon[selid] = buffer
					vector.icon[selid].id = selid - 1
				end
			end
			if suit.Button("Load colors ("..tostring(_rs)..","..tostring(_gs)..","..tostring(_bs)..","..tostring(_as)..")", suit.layout:row(256,20)). hit then
				_rt.text = tostring(_rs)
				_r.value = _rs
				selected.color[1] = _rs

				_gt.text = tostring(_gs)
				_g.value = _gs
				selected.color[2] = _gs

				_bt.text = tostring(_bs)
				_b.value = _bs
				selected.color[3] = _bs

				_at.text = tostring(_as)
				_a.value = _as
				selected.color[4] = _as
			end
			if suit.Button("Save colors", suit.layout:row(256,20)).hit then
				_rs = selected.color[1]
				_gs = selected.color[2]
				_bs = selected.color[3]
				_as = selected.color[4]
			end
			if suit.Button("Delete", suit.layout:row(256,20)).hit then
				local toMove = #vector.icon - selected.id
				local selid = selected.id
				for i = 0, toMove - 1 do
					vector.icon[selid+i+1].id = vector.icon[selid+i+1].id - 1
					vector.icon[selid+i] = vector.icon[selid+i+1]
				end
				vector.icon[#vector.icon] = nil
				selected = nil
			end
			if suit.Button("Back", suit.layout:row(256,20)).hit then
				selected = nil
			end
			local mx, my = love.mouse.getPosition()
			if mx <= res and my <= res then
				local px, py = getNearestGrid(mx, my, gridSize, res)
				pxs, pys = wToS(px, res), wToS(py, res)
				if selected.shape == "circle" then
					if love.mouse.isDown(1) then
						selected.radius = math.abs(distance(pxs, pys, selected.x, selected.y))
					elseif love.mouse.isDown(2) then
						selected.x = pxs
						selected.y = pys
					end
				elseif selected.shape == "rectangle" then
					if love.mouse.isDown(1) then
						selected.w = pxs - selected.x
						selected.h = pys - selected.y
					elseif love.mouse.isDown(2) then
						selected.x = pxs
						selected.y = pys
					end
				elseif selected.shape == "polygon" then
					if love.mouse.isDown(1) and not haspressed then
						haspressed = true
						selected.points[#selected.points+1] = pxs
						selected.points[#selected.points+1] = pys
					elseif love.mouse.isDown(2) and not haspressed2 then
						if #selected.points == 2 then
							local toMove = #vector.icon - selected.id
							local selid = selected.id
							for i = 0, toMove - 1 do
								vector.icon[selid+i+1].id = vector.icon[selid+i+1].id - 1
								vector.icon[selid+i] = vector.icon[selid+i+1]
							end
							vector.icon[#vector.icon] = nil
							selected = nil
						else
							selected.points[#selected.points] = nil
							selected.points[#selected.points] = nil
						end
						haspressed2 = true
					end
				end
			end
		elseif menu == "main" then
			if suit.Button("New shape", suit.layout:row(256,20)).hit then
				menu = "new"
			end
			if suit.Button("Shapes", suit.layout:row(256,20)).hit then
				menu = "shapes"
			end
			if suit.Button("File", suit.layout:row(256,20)).hit then
				menu = "file"
			end
			if suit.Button("Controls", suit.layout:row(256,20)).hit then
				menu = "controls"
			end
		elseif menu == "new" then
			suit.Label("Selected shape: "..(selectedShape or "none"), suit.layout:row(256,20))
			if suit.Button("Circle", suit.layout:row(256,20)).hit then
				selectedShape = "circle"
			end
			if suit.Button("Rectangle", suit.layout:row(256,20)).hit then
				selectedShape = "rectangle"
			end
			if suit.Button("Polygon", suit.layout:row(256,20)).hit then
				selectedShape = "polygon"
			end
			if suit.Button("Back", suit.layout:row(256,20)).hit then
				menu = "main"
			end
		elseif menu == "shapes" then
			if suit.Slider(slider, suit.layout:row(256,15)).changed then
				love.graphics.setBackgroundColor(slider.value,slider.value,slider.value)
			end
			for k, v in pairs(vector.icon) do
				if suit.Button(v.shape, {id = k}, suit.layout:row(256,20)).hit then
					selected = v
					_r.value = selected.color[1]
					_g.value = selected.color[2]
					_b.value = selected.color[3]
					_a.value = selected.color[4]

					_rt.text = tostring(selected.color[1])
					_gt.text = tostring(selected.color[2])
					_bt.text = tostring(selected.color[3])
					_at.text = tostring(selected.color[4])
				end
			end
			if suit.Button("Back", suit.layout:row(256,20)).hit then
				menu = "main"
			end
		elseif menu == "file" then
			if suit.Button("New", suit.layout:row(256,20)).hit then
				vector = {icon={},resolution=64}
			end
			if suit.Button("Save as "..filename.text..".hvf", suit.layout:row(256,20)).hit then
				love.filesystem.write(filename.text..".hvf", serialize(vector))
			end
			if suit.Button("Load from "..filename.text..".hvf", suit.layout:row(256,20)).hit then
				vector = deserialize(love.filesystem.read(filename.text..".hvf"))
			end
			suit.Input(filename, suit.layout:row(256,20))
			if suit.Button("Back", suit.layout:row(256,20)).hit then
				menu = "main"
			end
		elseif menu == "controls" then
			if suit.Button("Back", suit.layout:row(256,20)).hit then
				menu = "main"
			end
			suit.Label(
	[[Controls:

	Making new shapes:
	LMB and RMB to position shapes.
	Three sliders on right, RGBA
	]],suit.layout:row(256,20))
		end
	end

	function love.textinput(t)
	    suit.textinput(t)
	end

	function love.keypressed(Key)
		suit.keypressed(Key)
		if Key == "right" then
			if gridSize == 0 then
				gridSize = 1
			elseif gridSize < 128 then
				gridSize = gridSize * 2
				grid = renderGrid(gridSize, res)
			end
		elseif Key == "left" then
			if gridSize == 0 then
			elseif gridSize == 1 then
				gridSize = 0
			else
				gridSize = gridSize / 2
				grid = renderGrid(gridSize, res)
			end
		elseif Key == "up" then
			if selected and selected.id ~= 1 then
				local selid = selected.id
				local buffer = vector.icon[selid-1]
				vector.icon[selid-1] = selected
				vector.icon[selid-1].id = selid - 1
				vector.icon[selid] = buffer
				vector.icon[selid].id = selid + 1
			end
		elseif Key == "down" then
			if selected and selected.id ~= #vector.icon then
				local selid = selected.id
				local buffer = vector.icon[selid+1]
				vector.icon[selid+1] = selected
				vector.icon[selid+1].id = selid + 1
				vector.icon[selid] = buffer
				vector.icon[selid].id = selid - 1
			end
		elseif Key == "escape" then
			selected = nil
		elseif Key == "space" then
		elseif Key == "s" then
			if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lcrtl") then
				love.filesystem.write(filename.text..".hvf", serialize(vector))
			end
		end
	end

	function love.mousepressed(x, y, button)
		if button == 1 then
			if x <= res and y <= res then
				px, py = getNearestGrid(x, y, gridSize, res)
				if selectedShape ~= nil then
					local id = firstEmptyKey(vector.icon)
					if selectedShape == "circle" then
						vector.icon[id] = {
							shape = "circle",
							color = {255,255,255,255},
							x = wToS(px, res), y = wToS(py, res),
							radius = wToS(getStep(gridSize, res), res)
						}
					elseif selectedShape == "rectangle" then
						vector.icon[id] = {
							shape = "rectangle",
							color = {255,255,255,255},
							x = wToS(px, res), y = wToS(py, res),
							w = wToS(getStep(gridSize, res), res),
							h = wToS(getStep(gridSize, res), res),
						}
					elseif selectedShape == "polygon" then
						vector.icon[id] = {
							shape = "polygon",
							color = {255,255,255,255},
							points = {wToS(px, res),wToS(py, res)},
						}
						haspressed = true
					end
					_r.value = 255
					_g.value = 255
					_b.value = 255
					_a.value = 255
					vector.icon[id].id = id
					selected = vector.icon[id]
					selectedShape = nil
				end
			end
		end
	end

	function love.mousereleased(x, y, button)
		if button == 1 then
			haspressed = false
			px, py = nil, nil
		elseif button == 2 then
			haspressed2 = false
		end
	end

	function love.wheelmoved(x, y)
		local mx, my = love.mouse.getPosition()
		if mx > res then
			scroll = scroll + y * 50
		end
	end
elseif MODE == "parto" then
	local particleFile = ""

end