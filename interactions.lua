local f = require "framer"

local c

local interactions = {}

function interactions.link(module)
  c = module
end

function interactions.reduceHealth(self, other)
  table.insert(particles, c.newSpark(self.body:getX(), self.body:getY()))
  local x, y = self.body:getX(), self.body:getY()
  table.insert(self.frame.creates, function() return c.newEnemyBullet(x, y) end)
  --table.insert(particles, c.newExplosion(self.body:getX(), self.body:getY()))
  --table.insert(objects, c.newEnemyBasic(self.body:getX(), self.body:getY()))
  self.health = self.health - 1
end

function interactions.setPulse(self, other)
  self.pulse = 3
end

function interactions.changeColor(self, other)
  self.color = {math.random(255), math.random(255), math.random(255)}
end

function interactions.eliminateOther(self, other)
  other.health = -1
end

function interactions.eliminateSelf(self, other)
  self.health = -1
end

return interactions
