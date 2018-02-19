local h = require "helpers"
local c

local behaviors = {}

function behaviors.link(module)
  c = module
end

function behaviors.followv(self)
  if object.player ~= nil then
    local x, y = h.normalToObject(self, object.player)
    self.body:setLinearVelocity(x * 30, y * 30)
  end
end

function behaviors.followf(self)
  if objects.player ~= nil then
    local x, y = h.normalToObject(self, objects.player)
    self.body:applyForce(x * 30, y * 30)
  end
end

function behaviors.encircle(self)
  if objects.player ~= nil then
    local x, y = self.body:getPosition()
    local px, py = objects.player.body:getPosition()

    local fx, fy = h.normalToPoint(x, y, px, py)

    -- local angleToPlayer = math.atan2(fy, fx)
    -- local scramAngle = angleToPlayer + math.pi / 2
    -- local rx, ry = 10 * math.cos(scramAngle ), 10 * math.sin(scramAngle)
    local rx, ry = -fy, fx -- maybe put this in helpers


    -- local magnitude = h.distance(x, y, px, py)
    -- local scalar = magnitude - 400
    scalar = 50
    self.body:applyForce(fx * scalar + rx * 10, fy * scalar + ry * 10)
  end
end

function behaviors.reducePulse(self)
  if self.pulse > self.fuzziness then
    self.pulse = self.pulse - gdt * 20
  end
  if self.pulse < self.fuzziness then
    self.pulse = self.fuzziness
  end
end

-- function probably not needed anymore
-- function behaviors.checkIfDead(self)
--   if self.health <= 0 then
--     self.destroy(self)
--   end
-- end

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
