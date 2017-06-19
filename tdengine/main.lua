require("functions")
gamera = require("gamera")
windowScale = 0.7
love.window.setMode(1920*windowScale,1080*windowScale,{vsync=false})
camera = gamera.new(0,0,1520,1080)
camera:setWindow(0,0,1520*windowScale,1080*windowScale)
camera:setScale(windowScale)
camera:setAngle(2)
MovingEnt = require("classes/MovingEnt")
Enemy = require("classes/Enemy")
Tower = require("classes/Tower")
_G.curmap = require("maps/testmap")
_G.money = 2000

local iconSVG = require("icons/icons")
icons = {}
for k, v in pairs(iconSVG) do
	icons[k] = renderVector(v.icon, v.resolution, 8)
end
local bg = love.graphics.newImage("Beta_Map.png")

local suit = require("suit")

ps = love.graphics.newParticleSystem(love.graphics.newImage("icons/particle.png"), 2500)
ps:setParticleLifetime(1,3)
ps:setEmissionRate(0)
ps:setSizes(1,0)
ps:setLinearAcceleration(-400, -400, 400, 400)
ps:setColors(255, 255, 255, 255, 255, 255, 255, 0)

Enemy.new("drono")
function love.draw()
	camera:draw(function(x,y,w,h)
		love.graphics.setColor(255,255,255)
		love.graphics.draw(bg)
		for k, v in pairs(MovingEnt.getAll()) do
			v:draw()
		end
		love.graphics.draw(ps)
	end)
	suit.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(_G.money))
end

function love.update(Dt)
	suit.layout:reset(1520*windowScale, 0)
	suit.layout:padding(10*windowScale,10*windowScale)
	ps:update(Dt)
	for k, v in pairs(Enemy.getAll()) do
		v:move(Dt)
		v:update(Dt)
	end
	for k, v in pairs(Tower.getAll()) do
		v:update(Dt)
		v:tryAttack()
	end
	local seltower = Tower.getSelected()
	local heldtower = Tower.getHeld()
	if seltower ~= nil then
		for k, v in pairs(seltower.upgrades) do
			local upgrade = Tower.getPrefabs()[k]
			if suit.Button("Upgrade to "..k.." for $"..tostring(upgrade.price), suit.layout:row(400*windowScale,30*windowScale)).hit then
				seltower:upgradeTo(k):select()
			end
		end
		if suit.Button("Sell for $"..tostring(seltower.sellValue), suit.layout:row(400*windowScale,30*windowScale)).hit then
			seltower:sell()
		end
		if suit.Button("Cancel", suit.layout:row(400*windowScale,30*windowScale)).hit then
			Tower.deselect()
		end
	elseif heldtower ~= nil then
		if suit.Button("Cancel", suit.layout:row(400*windowScale,30*windowScale)).hit then
			heldtower:remove()
		end
	else
		for k, v in pairs(Tower.getPrefabs()) do
			if v.buildable then
				if suit.Button(k.." $"..tostring(v.price), suit.layout:row(400*windowScale,30*windowScale)).hit then
					Tower.new(k):pickup()
				end
			end
		end
	end
end

function love.textinput(t)
    suit.textinput(t)
end

function love.keypressed(Key)
	suit.keypressed(Key)
	if Key == "escape" then
		love.event.quit()
	elseif Key == "up" then
		Enemy.new("drono")
	end
end

function love.mousepressed(x, y, button)
	local _, _, wx, wy = camera:getWindow()
	if button == 1 then
		if x <= wx and y <= wy then
			local htower = Tower.getHeld()
			if htower ~= nil then
				htower:buy()
			else
				local foundtower = false
				for k, v in pairs(Tower.getAll()) do
					if distance(x, y, v.x*windowScale, v.y*windowScale) < v.radius then
						v:select()
						foundtower = true
						break
					end
				end
				if not foundtower then
					Tower.deselect()
				end
			end
		end
	elseif button == 2 then
		local htower = Tower.getHeld()
		if htower then
			htower:remove()
		end
	end
end