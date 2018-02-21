--local b = require "behaviors"
local i = require "interactions"
local b = require "behaviors"
local d = require "draw"
local h = require "helpers"
local t = require "transformations"
local f = require "framer"

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
      collisions = {bullet = {i.reduceHealth,  i.setPulse, i.eliminateOther}},
      behaviors = {b.followf, b.reducePulse},
      health = 1
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
    if self.relationships[object.kind] ~= nil then
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
  enemy.draw = function(self) d.gradientLine(d.objectData(self), 10, 8, self.pulse, 50) end

  --get the settings from the world, if there are any.
  -- if level ~= nil then level:setObject(enemy) end
  return enemy
end

function constructors.newEnemyEncircler(x, y, level)
  local enemy = constructors.newEnemyBasic(x, y, level)
  enemy.color = {200, 0, 200}
  enemy.behaviors = {b.encircle, b.reducePulse}
  return enemy
end

function constructors.newBullet(x, y)
  local bullet = {}
  bullet.kind = 'bullet'
  bullet.color = {math.random(255), math.random(255), math.random(255)}
  bullet.destroy = b.bulletDestroy
  bullet.collisions = {enemy = {}}

  --get the settings from the world, if there are any.
  -- if level ~= nil then level:setObject(bullet) end

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
  bullet.draw = function(self) d.gradientLine(d.objectData(self), 5, 3, 0.5) end
  return bullet
end

function constructors.newPickup(x, y)
  local pickup = constructors.newBullet(x, y)
  pickup.kind = 'collectable'
  pickup.color = {0, 255, 0}
  pickup.fixture:setSensor(true)
  return pickup
end

function constructors.newPlayer(x, y)
  local player = {}
  player.kind = 'player'
  player.color = {255, 0, 0}
  player.collisions = {}

  player.canShoot = true
  player.canShootTimerMax = 0.05
  player.canShootTimer = player.canShootTimerMax

  --get the settings from the world, if there are any.
  --if level ~= nil then level:setObject(player) end

  player.health = 1
  -- player.aim = 0
  player.body = love.physics.newBody(world, x, y, 'dynamic')
  player.shape = love.physics.newCircleShape(25)
  player.behaviors = {
    function(self)
      -- TODO make this directional
      if love.keyboard.isDown("right", "d") then
        self.body:applyForce(1500, 0)
      elseif love.keyboard.isDown("left", "a") then
        self.body:applyForce(-1500, 0)
      end
      if love.keyboard.isDown("up", "w") then
        self.body:applyForce(0, -1500)
      elseif love.keyboard.isDown("down", "s") then
        self.body:applyForce(0, 1500)
      end
    end,
    function(self)
      local mousex, mousey = t.screenToWorldPoint(love.mouse.getPosition())
      -- TODO make all variable names camel case
      local playerx, playery = self.body:getPosition()
      local shotx, shoty = h.normalToPoint(playerx, playery, mousex, mousey)
      -- objects.player.aim = math.atan2(shoty, shotx)
      local bulletx, bullety = h.scaledNormalToPointPos(playerx, playery, mousex, mousey, 40)

      if self.canShootTimer > 0 then
        self.canShootTimer = self.canShootTimer - gdt
      else
        self.canShoot = true
      end

      if self.canShoot then
        local bullet = constructors.newBullet(bulletx, bullety)
        bullet.body:setLinearVelocity(shotx * 400, shoty * 400)
        --table.insert(objects, bullet)
        f.create(self.frame, bullet)
        self.canShootTimer = self.canShootTimerMax
        self.canShoot = false
      end
    end
  }
  player.fixture = love.physics.newFixture(player.body, player.shape, 1)
  player.fixture:setRestitution(0.1)
  player.body:setLinearDamping(10)
  player.fixture:setUserData(player)
  player.draw = function(self) d.gradientLine(d.objectData(self), 9, 7, 1) end
  return player
end

function constructors.newGround(x, y, width, height)
  local ground = {}
  ground.kind = 'passive'
  ground.collisions = {}

  --get the settings from the world, if there are any.
  --if level ~= nil then level:setObject(ground) end

  ground.health = 1
  ground.body = love.physics.newBody(world, x, y, 'static')
  ground.shape = love.physics.newRectangleShape(width, height)
  ground.fixture = love.physics.newFixture(ground.body, ground.shape)
  ground.fixture:setUserData(ground)
  ground.color = {72, 160, 14}
  ground.draw = function(self) d.gradientLine(d.objectData(self), 9, 7, 1) end
  return ground
end

function constructors.newBorder(left, top, right, bottom)
  local border = {}
  border.kind = 'passive'
  border.collisions = {}

  --get the settings from the world, if there are any.
  --if level ~= nil then level:setObject(border) end

  border.health = 1
  border.body = love.physics.newBody(world, x, y, 'static') -- change x, y
  -- maybe make this in a loop, but it might not make the code much cleaner
  local points1 = h.circleSectionPoints(right, bottom, 20, 30, 0, math.pi * 1/2)
  local points2 = h.circleSectionPoints(left, bottom, 20, 30,  math.pi * 1/2, math.pi)
  local points3 = h.circleSectionPoints(left, top, 20, 30, math.pi, math.pi * 3/2)
  local points4 = h.circleSectionPoints(right, top, 20, 30, math.pi * 3/2, math.pi * 2)

  local points = h.combine(points1, points2, points3, points4)

  -- local points = {0, 0, 10, 10, 20, 20, 30, 30, 40, 40, 100, 2}
  border.shape = love.physics.newChainShape(true, points)
  border.fixture = love.physics.newFixture(border.body, border.shape)
  border.fixture:setUserData(border)
  border.color = {110, 94, 255}
  border.draw = function(self) d.gradientLine(d.objectData(self), 12, 10, 1) end
  return border
end

-- particles

function constructors.newSpark(x, y)
  local spark = {}
  spark.kind = 'spark'

  --get the settings from the world, if there are any.
  --if level ~= nil then level:setObject(spark) end

  spark.x = x
  spark.y = y
  spark.xvel = math.random(-800, 800)
  spark.yvel = math.random(-800, 800)
  spark.damping = 0.01
  spark.lifetime = 0.2
  spark.color = {math.random(255), math.random(255), math.random(255)}
  spark.size = 5
  spark.schange = -3
  spark.draw = function(self)
    local data = {
      type = 'chain',
      points = {self.x, self.y, self.x + spark.xvel / 40, self.y + spark.yvel / 40},
      color = spark.color
    }
    d.gradientLine(data, self.size, 5, 1, 20)
  end
  return spark
end

function constructors.newExplosion(x, y)
  local explosion = {}
  explosion.kind = 'explosion'

  --get the settings from the world, if there are any.
  --if level ~= nil then level:setObject(explosion) end

  explosion.x = x
  explosion.y = y
  explosion.xvel = 0
  explosion.yvel = 0
  explosion.damping = 0
  explosion.lifetime = 0.5
  explosion.color = {math.random(255), math.random(255), math.random(255)}
  explosion.size = 75
  explosion.schange = -100
  explosion.draw = function(self)
    local data = {
      type = 'circle',
      x = self.x,
      y = self.y,
      radius = self.size,
      color = explosion.color
    }
    d.gradientLine(data, 5, 2, 1, 200)
  end
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
