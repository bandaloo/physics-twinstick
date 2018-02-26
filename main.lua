local c = require "constructors"
local h = require "helpers"
local d = require "draw"
local v = require "view"
local t = require "transformations"
local f = require "framer"

debug = true

function love.load(arg)
  -- love.window.setFullscreen(true)
  love.graphics.setBackgroundColor(255, 255, 255)

  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()

  worldWidth = 1280
  worldHeight = 720

  -- would like to get rid of globals

  cameraX = worldWidth / 2
  cameraY = worldHeight / 2

  currentDepth = 0
  zoomAmount = 1
  totalZoomAmount = 1

  worldToScreenRatio = worldWidth / screenWidth

  -- xScreenOffset = screenWidth / 8 -- this is just a test
  -- yScreenOffset = screenHeight / 8
  xWorldOffset = 0
  yWorldOffset = 0
  xScreenOffset = 0
  yScreenOffset = 0

  totalX = 0
  totalY = 0
  worldSize = 1

  --v.setOffsets()

  borderWidth = 60
  borderHeight = 60


  gameMeter = 64
  love.physics.setMeter(gameMeter)

  world1 = love.physics.newWorld(0, 0, true)
  world1:setCallbacks(beginContact)

  frames = {}

  level = c.newLevel()

  frame1 = {}
  frame1.objects = {}
  frame1.particles = {}
  frame1.creates = {}
  frame1.world = world1
  frame1.level = level
  frame1.totalX = 0
  frame1.totalY = 0
  frame1.size = 1
  frame1.depth = 1

  objects = frame1.objects
  particles = frame1.particles
  world = frame1.world

  table.insert(frames, frame1)

  -- objects.ground = c.newGround(screenWidth / 2, screenHeight - 20, screenWidth, 20)
  f.create(frame1, c.newBorder(borderWidth, borderHeight, worldWidth - borderWidth, worldHeight - borderHeight), 'border')
  f.create(frame1, c.newPlayer(worldWidth / 2, worldHeight / 2), 'player')
  for i = 0, 10 do
    f.create(frame1, c.newEnemyBasic(80 + i * 60, 300))
  end

  world2 = love.physics.newWorld(0, 0, true)
  world2:setCallbacks(beginContact)

  frame2 = {}
  frame2.objects = {}
  frame2.particles = {}
  frame2.creates = {}
  frame2.world = world2
  frame2.totalX = 0
  frame2.totalY = 0
  frame2.size = 1
  frame2.depth = 2

  objects = frame2.objects
  particles = frame2.particles
  world = frame2.world

  table.insert(frames, frame2)

  f.create(frame2, c.newBorder(borderWidth, borderHeight, worldWidth - borderWidth, worldHeight - borderHeight), 'border')

  f.create(frame2, c.newPlayer(200, 200), 'player')
  f.create(frame2, c.newEnemyBasic(100, 100), 'enemy')

  world3 = love.physics.newWorld(0, 0, true)
  world3:setCallbacks(beginContact)

  frame3 = {}
  frame3.objects = {}
  frame3.particles = {}
  frame3.creates = {}
  frame3.world = world3
  frame3.totalX = 0
  frame3.totalY = 0
  frame3.size = 1
  frame3.depth = 1.5

  objects = frame3.objects
  particles = frame3.particles
  world = frame3.world

  table.insert(frames, frame3)

  f.create(frame3, c.newBorder(borderWidth, borderHeight, worldWidth - borderWidth, worldHeight - borderHeight), 'border')

  f.create(frame3, c.newPlayer(200, 200), 'player')
  f.create(frame3, c.newEnemyBasic(100, 100), 'enemy')

  table.sort(frames, function(f1, f2) return f1.depth > f2.depth end)
end

function love.update(dt)
  gdt = dt

  -- v.positionCamera(objects.player.body:getX(), objects.player.body:getY())
  -- v.zoomCamera(0.1)
  -- worldToScreenRatio = worldToScreenRatio + dt * 0.1 -- this is just a test get rid of this
  for i, frame in ipairs(frames) do
    world = frame.world
    setFrameInfo(frame)
    world:update(dt) -- maybe update world after this stuff has been done
    f.spawn(frame)
    for key, particle in pairs(particles) do
      particle.x = particle.x + particle.xvel * dt
      particle.y = particle.y + particle.yvel * dt
      particle.lifetime = particle.lifetime - dt
      local speed = h.distance(0, 0, particle.xvel, particle.yvel)
      if speed ~= 0 then
        speed = speed - particle.damping * speed * dt
        particle.xvel, particle.yvel = h.normalizeThenScale(particle.xvel, particle.yvel, speed)
      end
      particle.size = particle.size + particle.schange * dt
      if particle.lifetime <= 0 then
        particles[key] = nil
      end
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
  end
end


function love.draw(dt)
  -- love.graphics.printf(objects.player.aim, 0, 0, 200, 'left')
  --v.panCamera(100, 100)
  -- totalZoomAmount = totalZoomAmount + 0.01
  for i, frame in ipairs(frames) do
    --world = frame.world
    setFrameInfo(frame)
    if i == 3 then
      local camx, camy = frames[3].objects.player.body:getPosition() -- this is a test get rid of this later
      v.positionCamera(totalX + camx, totalY + camy)
    end
    -- frame.cameraX = cameraX
    -- frame.cameraY = cameraY
    -- frame.zoomAmount = zoomAmount

    love.graphics.setColor(72, 160, 14) -- do we need this?
    for key, object in pairs(objects) do
      object:draw()
    end

    for key, particle in pairs(particles) do
      particle:draw()
    end
  end
end

function beginContact(fixture1, fixture2, coll)
  -- this is a flip flop so figure out a better way to do this
  object1 = fixture1:getUserData() -- make this compatible with sensors
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

function setFrameInfo(frame)
  objects = frame.objects
  particles = frame.particles
  creates = frame.creates
  totalX = frame.totalX
  totalY = frame.totalY
  worldSize = frame.size
  zoomAmount = frame.depth + currentDepth
  v.setOffsets()
end
