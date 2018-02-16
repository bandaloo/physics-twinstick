--local b = require "behaviors"
local i = require "interactions"
local b = require "behaviors"
local d = require "draw"

local constructors = {}

b.link(constructors)
i.link(constructors)

function constructors.newLevel()
  local level = {}
  level.kind = 'level'
  level.solidBoundries = true
  level.relationships = {
    enemy = {
      destroy = b.enemyDestroy,
      collisions = {bullet = {i.reduceHealth,  i.setPulse, i.eliminateOthers}},
      behaviors = {b.followf, b.reducePulse},
    },
    bullet = {
      destroy = b.bulletDestroy,
      collisions = {enemy = {}},
      behaviors = {},
    },
    player = {
      collisions = {},
    }
  }
  level.setObject = function(self, object)
    if(self.relationships[object.kind] ~= nil) then
      for key, value in pairs(self.relationships[object.kind]) do
        object[key] = value
      end
    end
  end
  return level
end

-- objects

function constructors.newEnemyBasic(x, y, level)
  local enemy = {}
  enemy.kind = 'enemy'
  enemy.color = {0, 200, 200}

  --defaults
  enemy.destroy =  b.enemyDestroy
  enemy.collisions = {bullet = {i.reduceHealth, i.changeColor, i.setPulse, i.eliminateOther}}
  enemy.behaviors = {b.followf, b.reducePulse}

  --get the settings from the world, if there are any.
  if(level ~= nil) then level:setObject(enemy) end


  enemy.health = 10
  enemy.body = love.physics.newBody(world, x, y, 'dynamic')
  enemy.shape = love.physics.newRectangleShape(0, 0, 40, 40)
  enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 2)
  enemy.fixture:setRestitution(0.1)
  enemy.fixture:setUserData(enemy)
  enemy.body:setLinearDamping(0.4)
  enemy.body:setLinearVelocity(0, 0)
  enemy.body:setMass(0.1)
  enemy.fuzziness = 1
  enemy.pulse = enemy.fuzziness
  enemy.draw = function(self) d.gradientLine(self, 10, 8, self.pulse) end
  return enemy
end

function constructors.newBullet(x, y)
  local bullet = {}
  bullet.kind = 'bullet'
  bullet.color = {math.random(255), math.random(255), math.random(255)}
  bullet.destroy = b.bulletDestroy
  bullet.collisions = {enemy = {}}
  bullet.health = 1
  bullet.lifetime = 10
  bullet.body = love.physics.newBody(world, x, y, 'dynamic')
  bullet.shape = love.physics.newRectangleShape(0, 0, 10, 10)
  bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 2)
  bullet.fixture:setRestitution(0.1)
  bullet.body:setLinearDamping(0.4)
  bullet.body:setMass(0.1)
  bullet.fixture:setUserData(bullet)
  bullet.fixture:setCategory(2)
  bullet.fixture:setMask(2)
  bullet.draw = function(self) d.gradientLine(self, 5, 3, 0.5) end
  return bullet
end

function constructors.newPlayer(x, y)
  local player = {}
  player.kind = 'player'
  player.color = {255, 0, 0}
  player.collisions = {}
  player.health = 1
  player.body = love.physics.newBody(world, screenWidth / 2, screenHeight / 2, 'dynamic')
  player.shape = love.physics.newCircleShape(25)
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)
  player.fixture:setRestitution(0.1)
  player.body:setLinearDamping(10)
  player.fixture:setUserData(player)
  player.draw = function(self) d.gradientLine(self, 9, 7, 1) end
  return player
end

function constructors.newGround(x, y, width, height)
  local ground = {}
  ground.kind = 'passive'
  ground.collisions = {}
  ground.health = 1
  ground.body = love.physics.newBody(world, x, y)
  ground.shape = love.physics.newRectangleShape(width, height)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  ground.fixture:setUserData(ground)
  ground.color = {72, 160, 14}
  ground.draw = function(self) d.gradientLine(self, 9, 7, 1) end
  return ground
end

-- particles

function constructors.newSpark(x, y)
  local spark = {}
  spark.kind = 'spark'
  spark.x = x
  spark.y = y
  spark.xvel = math.random(-200, 200)
  spark.yvel = math.random(-200, 200)
  spark.damping = 0.1
  spark.lifetime = 1
  spark.color = {50, 200, 40}
  spark.size = 5
  spark.schange = -3
  return spark
end

function constructors.newExplosion(x, y)
  local explosion = {}
  explosion.kind = 'explosion'
  explosion.x = x
  explosion.y = y
  explosion.xvel = 0
  explosion.yvel = 0
  explosion.damping = 0
  explosion.lifetime = 0.5
  explosion.color = {200, 200, 0}
  explosion.size = 75
  explosion.schange = -100
  return explosion
end

-- destructors

-- function constructors.enemyDestroy(self)
--   if self.health <= 0 then
--     for i = 1, 16 do
--       table.insert(particles, constructors.newSpark(self.body:getX(), self.body:getY()))
--     end
--     self.body:destroy()
--     objects[currentKey] = nil
--   end
-- end

--function constructors.enemyDestroy

return constructors
