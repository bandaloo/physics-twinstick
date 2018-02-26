local v = require "view"

local framer = {}

function framer.spawn(frame)
  for i, func in ipairs(frame.creates) do
    local object = func()
    framer.create(frame, object)
  end
  frame.creates = {}
end

function framer.setFrameInfo(frame)
  objects = frame.objects
  particles = frame.particles
  creates = frame.creates
  totalX = frame.totalX
  totalY = frame.totalY
  frameSize = frame.size
  depthScalar = frame.depth + currentDepth
  v.setOffsets()
end

function framer.create(frame, object, key)
  object.frame = frame
  if frame.level ~= nil then
    frame.level:setObject(object)
  end
  if key == nil then
    table.insert(objects, object)
  else
    objects[key] = object
  end
end

return framer
