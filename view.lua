--local d = require "draw"
local t = require "transformations"

local view = {}

function view.setOffsets()
  xWorldOffset = ((worldWidth * zoomAmount / 2) - cameraX) * (1 / worldSize) + totalX
  yWorldOffset = ((worldHeight * zoomAmount / 2) - cameraY) * (1 / worldSize) + totalY
  xScreenOffset = t.worldToScreenScalar(xWorldOffset) * (1 / worldSize)
  yScreenOffset = t.worldToScreenScalar(yWorldOffset) * (1 / worldSize)
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
  zoomAmount = zoomAmount + dz * gdt
  view.setOffsets()
end

function view.scaleCamera(z)
  zoomAmount = z
  view.setOffsets()
end

return view
