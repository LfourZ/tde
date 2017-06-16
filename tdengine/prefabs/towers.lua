return {
	tanko = {
		resolution = 64,
		buildable = true,
		radius = 28, --This is used for hitbox detection.
		range = 200, --Obvious
		price = 100, --If I have to explain this one to you, you aren't a meme artist
		damage = 15, --Damage per shot.
		firerate = 1, --Attack cooldown. 1 = 1 shot per second, 2 = 0.5 shots per second, 0.2 = 5 shots per second.
		onAttack = function(self, other)
			self.rot = math.atan2(self.y - other.y, self.x - other.x)
			other:hit(self)
		end,
	},
	areo = {
		resolution = 64,
		buildable = true,
		radius = 32,
		range = 100,
		price = 100,
		damage = 10,
		firerate = 2,
		onAttack = function(self, other)
			for k, v in pairs(Enemy.getAll()) do
				if distance(v.x,v.y,self.x,self.y) < self.range then
					v:hit(self)
					ps:setPosition(v.x, v.y)
					ps:emit(25)
				end
			end
		end,
		upgrades = {
			oreo = true,
		}
	},
	oreo = {
		resolution = 64,
		buildable = false,
		radius = 32,
		range = 200,
		price = 200,
		damage = 3,
		firerate = 0.1,
		onAttack = function(self, other)
			for k, v in pairs(Enemy.getAll()) do
				if distance(v.x,v.y,self.x,self.y) < self.range then
					v:hit(self)
					ps:setPosition(v.x, v.y)
					ps:emit(5)
				end
			end
		end,
	},
	bogey = {
		resolution = 128,
		buildable = true,
		radius = 58,
		range = 300,
		price = 2000,
		damage = 40,
		firerate = 4,
		onAttack = function(self, other)
			self.rot = math.atan2(self.y - other.y, self.x - other.x)
			for k, v in pairs(Enemy.getAll()) do
				if distance(other.x, other.y, v.x, v.y) < 100 then
					v:hit(self)
				end
			end
			ps:setPosition(other.x, other.y)
			ps:emit(25)
		end,
	},
	icy = {
		resolution = 64,
		buildable = true,
		radius = 28,
		range = 120,
		price = 150,
		damage = 2,
		firerate = 1,
		onAttack = function(self, other)
			for k, v in pairs(Enemy.getAll()) do
				if distance(v.x, v.y, self.x, self.y) < self.range then
					if not v.statusEffects.slowed then
						v.statusEffects.slowed = {duration=5}
						v.color = {150,150,255}
						v.speed = v.speed / 2
					end
				end
			end
		end,
		onUpdate = function(self, Dt)
			self.rot = self.rot + Dt / 2
		end
	}
}