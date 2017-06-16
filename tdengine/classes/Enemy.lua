local Enemy = {}
Enemy.__index = Enemy
setmetatable(Enemy, {__index = MovingEnt})

local prefabenemies = require("prefabs/enemies")
local enemies = {}

function Enemy.new(data)
	local name
	if type(data) == "string" then
		name = data
		data = prefabenemies[data]
	end
	data = data or {}
	local _ptype = MovingEnt.new(data)

	_ptype.name = name or data.name
	_ptype.x = _ptype.x or _G.curmap.path[1][1]+1
	_ptype.y = _ptype.y or _G.curmap.path[1][2]+1
	_ptype.health = data.health or 100
	_ptype.maxhealth = data.maxhealth or 100
	_ptype.icon = data.icon or _ptype.name
	_ptype.w, _ptype.h = icons[_ptype.icon]:getDimensions()
	_ptype.rot = data.rot or 0
	_ptype.scale = data.scale or 1
	_ptype.w, _ptype.h = _ptype.w * _ptype.scale, _ptype.h * _ptype.scale
	_ptype.progress = 1
	_ptype.speed = data.speed or 100
	_ptype.reward = data.reward or 10
	_ptype.onDead = data.onDead or function() end
	_ptype.onHit = data.onHit or function() end
	_ptype.onUpdate = data.onUpdate or function() end
	_ptype.statusEffects = data.statusEffects or {}

	_ptype.subid = firstEmptyKey(enemies)

	enemies[_ptype.subid] = _ptype
	setmetatable(_ptype, Enemy)

	return _ptype
end

function Enemy.getAll()
	return enemies
end

function Enemy:update(Dt)
	self.onUpdate(self, Dt)
	for k, v in pairs(self.statusEffects) do
		v.duration = v.duration - Dt
		if v.duration <= 0 then
			if k == "slowed" then
				self.speed = prefabenemies[self.name].speed
				self.color = {255,255,255,255}
			end
			self.statusEffects[k] = nil
		end
	end
end

function Enemy:subRemove()
	enemies[self.subid] = nil
end

function Enemy:draw()
	love.graphics.setColor(self.color)
	love.graphics.draw(icons[self.icon], self.x, self.y, self.rot, self.scale, self.scale, self.w / 2, self.h / 2)
	local healthratio = self.health / self.maxhealth
	local wh, hh = self.w / 2, self.h / 2
	love.graphics.setColor(0,255,0)
	love.graphics.line(self.x-wh,self.y+hh+10,self.x-wh+self.w*healthratio,self.y+hh+10)
	love.graphics.setColor(255,0,0)
	love.graphics.line(self.x-wh+self.w*healthratio,self.y+hh+10,self.x+wh,self.y+hh+10)
end

function Enemy:move(Dt)
	local x1, x2, y1, y2 = _G.curmap.path[self.progress][1], self.x, _G.curmap.path[self.progress][2], self.y
	local dx, dy = x1 - x2, y1 - y2
	local d = math.sqrt(dx^2 + dy^2)
	local ux, uy = dx / d, dy / d
	self.x = self.x + ux * self.speed * Dt
	self.y = self.y + uy * self.speed * Dt
	self.rot = math.atan2(uy, ux)
	if math.abs(dx) < 1 and math.abs(dy) < 1 then
		if self.progress < #_G.curmap.path then
			self.progress = self.progress + 1
		else
			self:remove()
		end
	end
end

function Enemy:hit(other)
	self.onHit(self, other)
end

function Enemy:dead(other)
	self.onDead(self, other)
end

return Enemy