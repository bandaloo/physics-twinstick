local d = require "draw"

local view = {}

function view.setOffsets()
  -- xWorldOffset = -(cameraX - (worldWidth * zoomAmount / 2))
  -- yWorldOffset = -(cameraY - (worldHeight * zoomAmount / 2))
  xWorldOffset = ((worldWidth * zoomAmount / 2) - cameraX)
  yWorldOffset = ((worldHeight * zoomAmount / 2) - cameraY)
  xScreenOffset = d.worldToScreenScalar(xWorldOffset)
  yScreenOffset = d.worldToScreenScalar(yWorldOffset)
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
  -- worldWidth = worldWidth - worldWidth * dz * gdt
  -- worldHeight = worldHeight - worldHeight * dz * gdt
  -- worldToScreenRatio = worldToScreenRatio - worldToScreenRatio * dz * gdt
  -- cameraX = worldWidth / 2
  -- cameraY = worldHeight / 2
  -- view.setOffsets()
  zoomAmount = zoomAmount + dz * gdt
  view.setOffsets()
end

-- function view.scaleCamera(scale)
--   worldToScreenRatio = zoom
-- end

return view
