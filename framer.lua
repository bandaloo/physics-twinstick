local v = require "view"

local framer = {}

function framer.spawn(frame)
  for i, func in ipairs(frame.creates) do
    local object = func()
    table.insert(objects, object)
  end
  frame.creates = {}
end

function framer.setFrameInfo(frame)
  objects = frame.objects
  particles = frame.particles
  totalX = frame.totalX
  totalY = frame.totalY
  frameSize = frame.size
  depthScalar = frame.depth + currentDepth
  v.setOffsets()
end

return framer
