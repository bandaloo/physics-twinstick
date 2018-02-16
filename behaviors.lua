local h = require "helpers"
local c

local behaviors = {}

function behaviors.link(module)
  c = module
end

function behaviors.followv(self)
  local x, y = h.normalToPoint(self.body:getX(), self.body:getY(), objects.player.body:getX(), objects.player.body:getY())
  self.body:setLinearVelocity(x * 30, y * 30)
end

function behaviors.followf(self)
  local x, y = h.normalToPoint(self.body:getX(), self.body:getY(), objects.player.body:getX(), objects.player.body:getY())
  self.body:applyForce(x * 30, y * 30)
end

function behaviors.reducePulse(self)
  self.pulse = self.pulse - 0 -- take into account dt
end

-- function probably not needed anymore
function behaviors.checkIfDead(self)
  if self.health <= 0 then
    self.destroy(self)
  end
end

function behaviors.enemyDestroy(self)
  for i = 1, 16 do
    table.insert(particles, c.newSpark(self.body:getX(), self.body:getY()))
  end
  table.insert(particles, c.newExplosion(self.body:getX(), self.body:getY()))
end

function behaviors.bulletDestroy(self)
  for i = 1, 3 do
    table.insert(particles, c.newSpark(self.body:getX(), self.body:getY()))
  end
end

return behaviors
