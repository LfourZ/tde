local MovingEnt = {}
MovingEnt.__index = MovingEnt

local movingents = {}

function MovingEnt.new(data)
	data = data or {}
	local _ptype = {}

	_ptype.id = firstEmptyKey(movingents)
	_ptype.color = data.color or {255,255,255}

	setmetatable(_ptype, MovingEnt)

	movingents[_ptype.id] = _ptype
	return _ptype
end

function MovingEnt.getAll()
	return movingents
end

function MovingEnt:remove()
	self:subRemove()
	movingents[self.id] = nil
end

function MovingEnt:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.x, self.y, 10)
end

return MovingEnt