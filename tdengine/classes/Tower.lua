local Tower = {}
Tower.__index = Tower
setmetatable(Tower, {__index = MovingEnt})

local prefabtowers = require("prefabs/towers")

local towers = {}

function Tower.new(data)
	local name
	if type(data) == "string" then
		name = data
		data = prefabtowers[data]
	end
	data = data or {}
	local _ptype = MovingEnt.new(data)

	_ptype.name = name or data.name
	_ptype.buildable = data.buildable or false
	_ptype.x = data.x or 0
	_ptype.y = data.y or 0
	_ptype.radius = data.radius or 28
	_ptype.subid = firstEmptyKey(towers)
	_ptype.held = data.held or false
	_ptype.range = data.range or 100
	_ptype.icon = data.icon or _ptype.name
	_ptype.w, _ptype.h = icons[_ptype.icon]:getDimensions()
	_ptype.rot = data.rot or 0
	_ptype.scale = data.scale or 1
	_ptype.w, _ptype.h = _ptype.w * _ptype.scale, _ptype.h * _ptype.scale
	_ptype.price = data.price or 100
	_ptype.damage = data.damage or 15
	_ptype.firerate = data.firerate or 1
	_ptype.lastfired = 0
	_ptype.onAttack = data.onAttack or function() end
	_ptype.sellReturn = data.sellReturn or 0.75
	_ptype.sellValue = _ptype.sellReturn * _ptype.price
	_ptype.upgrades = data.upgrades or {}
	_ptype.onUpdate = data.onUpdate or function() end

	towers[_ptype.subid] = _ptype
	setmetatable(_ptype, Tower)

	if _ptype.held then
		heldtower = _ptype
	end

	return _ptype
end

function Tower:setData(data)
	for k, v in pairs(data) do
		self[k] = v
	end
end

function Tower:update(Dt)
	self.onUpdate(self, Dt)
end

function Tower.getPrefabs()
	return prefabtowers
end

function Tower.getAll()
	return towers
end

function Tower.getHeld()
	return heldtower
end

function Tower:subRemove()
	if heldtower and heldtower.id == self.id then
		heldtower = nil
	end
	if selectedtower and selectedtower.id == self.id then
		selectedtower = nil
	end
	towers[self.subid] = nil
end

function Tower:sell()
	_G.money = _G.money + self.sellValue
	self:remove()
end

function Tower:upgradeTo(other)
	if _G.money < prefabtowers[other].price then return end
	_G.money = _G.money - prefabtowers[other].price
	local sx, sy, sr = self.x, self.y, self.rot
	self:remove()
	local newtower = Tower.new(other)
	newtower:setData({x=sx,y=sy,rot=sr})
	return newtower
end


function Tower:draw()
	if not self.held then
		if selectedtower and selectedtower.id == self.id then
			love.graphics.setColor(200, 200, 200, 50)
			love.graphics.circle("fill", self.x, self.y, self.range)
		end
		love.graphics.setColor(self.color)
		love.graphics.draw(icons[self.icon], self.x, self.y, self.rot, self.scale, self.scale, self.w / 2, self.h / 2)
	else
		local mx, my = love.mouse.getPosition()
		local _, _, wx, wy = camera:getWindow()
		if mx < wx and my < wy then
			self.x, self.y = mx, my
		end
		if self:canPlace() then
			love.graphics.setColor(200, 200, 200, 50)
		else
			love.graphics.setColor(255, 50, 50, 50)
		end
		love.graphics.circle("fill", self.x, self.y, self.range)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(icons[self.icon], self.x, self.y, 0, self.scale, self.scale, self.w / 2, self.h / 2)
	end
end

function Tower:pickup()
	if heldtower == nil then
		self.held = true
		heldtower = self
	end
end

function Tower:overlapping(other)
	return overlapping(self.x, self.y, other.x, other.y, self.radius, other.radius)
end

function Tower:canPlace()
	for k, v in pairs(towers) do
		if self.id == v.id then
		else
			if self:overlapping(v) then
				return false
			end
		end
	end
	if _G.money < self.price then
		return false
	end
	return not onPath(self)
end

function Tower:drop()
	if self:canPlace() then
		self.held = false
		heldtower = nil
		return true
	end
	return false
end

function Tower:buy()
	if _G.money >= self.price then
		if self:drop() then
			_G.money = _G.money - self.price
			self:select()
		end
	end
end

function Tower:select()	
	selectedtower = self
end

function Tower.deselect()
	selectedtower = nil
end

function Tower.getSelected()
	return selectedtower
end

function Tower:tryAttack()
	if heldtower == self then return end
	for k, v in pairs(Enemy.getAll()) do
		if distance(self.x, self.y, v.x, v.y) < self.range then
			if self.lastfired + self.firerate <= love.timer.getTime() then
				self.lastfired = love.timer.getTime()
				self:attack(v)
			end
			break
		end
	end
end

function Tower:attack(other)
	self.onAttack(self, other)
end


return Tower