return {
	drono = {
		resolution = 64,
		health = 100, --Spawns at this health
		maxhealth = 100, --This is used for the health bar, and will be used for "target enemy with highest health %"
		speed = 150, --Speed at which the enemies move forward
		reward = 15, --How much money you get by killing them
		onHit = function(self, other)
		self.health = self.health - other.damage
		if self.health <= 0 then
			self:dead(other)
			end
		end,
		onDead = function(self, other)
			_G.money = _G.money + self.reward
			ps:setPosition(self.x, self.y)
			ps:emit(250)
			self:remove()
		end,
	}
}