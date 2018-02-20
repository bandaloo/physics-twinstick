--local d = require "draw"
local t = require "transformations"

local view = {}

function view.setOffsets()
  xWorldOffset = ((worldWidth * depthScalar / 2) - cameraX) * (1 / frameSize) + totalX
  yWorldOffset = ((worldHeight * depthScalar / 2) - cameraY) * (1 / frameSize) + totalY
  xScreenOffset = t.worldToScreenScalar(xWorldOffset) * (1 / frameSize)
  yScreenOffset = t.worldToScreenScalar(yWorldOffset) * (1 / frameSize)
end

function view.panCamera(dx, dy)
  cameraX = cameraX + dx * gdt
  cameraY = cameraY + dy * gdt
  view.setOffsets()
end

function view.positionCamera(x, y)
  cameraX = x
  cameraY = y
  view.setOffsets()
end

function view.zoomCamera(dz)
  depthScalar = depthScalar + dz * gdt
  view.setOffsets()
end

function view.scaleCamera(z)
  depthScalar = z
  view.setOffsets()
end

return view
