local c = require "constructors"
local h = require "helpers"

debug = true

function love.load(arg)
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()

  canShootTimerMax = 0.05
  canShootTimer = canShootTimerMax
  canShoot = true

  love.physics.setMeter(64)
  world = love.physics.newWorld(0, 9.81*64*0, true)
  world:setCallbacks(beginContact)
  objects = {}
  particles = {}

  objects.ground = c.newGround(screenWidth / 2, screenHeight - 20, screenWidth, 20)
  objects.player = c.newPlayer(screenWidth / 2, screenHeight / 2)
  objects.enemy = c.newEnemyBasic()
end

function love.update(dt)
  world:update(dt)

  local mousex, mousey = love.mouse.getPosition()

  for key, particle in pairs(particles) do
    particle.x = particle.x + particle.xvel * dt
    particle.y = particle.y + particle.yvel * dt
    -- do damping
    particle.lifetime = particle.lifetime - dt
    particle.size = particle.size + particle.schange * dt
    if particle.lifetime <= 0 then
      particles[key] = nil
    end
  end

  if canShootTimer > 0 then
    canShootTimer = canShootTimer - dt
  else
    canShoot = true
  end
  for key, object in pairs(objects) do
    currentKey = key
    if object.behaviors ~= nil then
      -- maybe switch these so a destroyed object won't do a thing for the frame after it's destroyed
      for i, func in ipairs(object.behaviors) do
        func(object)
      end
    end
    if object.health <= 0 or (object.lifetime ~= nil and object.lifetime < 0) then
      object.destroy(object)
      object.body:destroy()
      objects[currentKey] = nil
    end
    if object.lifetime ~= nil then
      object.lifetime = object.lifetime - dt
    end
  end

  local playerx, playery = objects.player.body:getPosition()
  local distance = math.sqrt((mousex - playerx) ^ 2 + (mousey - playery) ^ 2)
  local shotx = (mousex - playerx) / distance
  local shoty = (mousey - playery) / distance
  local bulletx = playerx + shotx * 40
  local bullety = playery + shoty * 40

  if love.keyboard.isDown("right", "d") then --press the right arrow key to push the player to the right
    objects.player.body:applyForce(800, 0)
  elseif love.keyboard.isDown("left", "a") then --press the left arrow key to push the player to the left
    objects.player.body:applyForce(-800, 0)
  end
  if love.keyboard.isDown("up", "w") then
    objects.player.body:applyForce(0, -800)
  elseif love.keyboard.isDown("down", "s") then
    objects.player.body:applyForce(0, 800)
  end
  if love.keyboard.isDown("space") then
    objects.player.body:setPosition(650/2, 650/2)
    objects.player.body:setLinearVelocity(0, 0)
  end

  if canShoot then
    local bullet = c.newBullet(bulletx, bullety)
    bullet.body:setLinearVelocity(shotx * 200, shoty * 200)
    table.insert(objects, bullet)
    canShootTimer = canShootTimerMax
    canShoot = false
  end
end


function love.draw(dt)
  -- love.graphics.setShader(myShader)
  -- love.graphics.printf(objects.enemy.health, 0, 0, 100, 'left')
  love.graphics.setColor(72, 160, 14)
  -- if hit then love.graphics.printf('hit', 0, 100, 100, 'left') end
  for key, object in pairs(objects) do
    love.graphics.setColor(object.color[1], object.color[2], object.color[3])
    if object.shape:getType() == 'circle' then
      love.graphics.circle('fill', object.body:getX(), object.body:getY(), object.shape:getRadius())
    elseif object.shape:getType() == 'polygon' then
      love.graphics.polygon('fill', object.body:getWorldPoints(object.shape:getPoints()))
    elseif object.shape:getType() == 'chain' then
      love.graphics.line(object.body:getWorldPoints(object.shape:getPoints()))
    end
  end

  for key, particle in pairs(particles) do
    love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3])
    if particle.kind == 'spark' then
      love.graphics.circle('fill', particle.x, particle.y, particle.size)
    end
    if particle.kind == 'explosion' then
      love.graphics.circle('fill', particle.x, particle.y, particle.size)
    end
  end
end

function beginContact(fixture1, fixture2, coll)
  object1 = fixture1:getUserData()
  object2 = fixture2:getUserData()
  if object1.collisions[object2.kind] ~= nil then
    for i, func in ipairs(object1.collisions[object2.kind]) do
      currentKey = i
      func(object1, object2)
    end
  end
  if object2.collisions[object1.kind] ~= nil then
    for i, func in ipairs(object2.collisions[object1.kind]) do
      currentKey = i
      func(object2, object1)
    end
  end
end
