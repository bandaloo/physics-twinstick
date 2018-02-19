local transformations = {}

function transformations.worldToScreenScalar(c)
  return c / (worldToScreenRatio * zoomAmount) * worldSize
end

function transformations.worldToScreenX(x)
  return (x / (worldToScreenRatio * zoomAmount) + xScreenOffset) * worldSize
end

function transformations.worldToScreenY(y)
  return (y / (worldToScreenRatio * zoomAmount) + yScreenOffset) * worldSize
end

function transformations.worldToScreenPoint(x, y)
  return transformations.worldToScreenX(x), transformations.worldToScreenY(y)
end

function transformations.screenToWorldPoint(x, y) -- figure out how size applies here
  return (x / worldSize - xScreenOffset) * worldToScreenRatio * zoomAmount, (y / worldSize - yScreenOffset) * worldToScreenRatio * zoomAmount
end

function transformations.worldToScreenPoints(points)
  local screenPoints = {}
  local offsets = {xScreenOffset, yScreenOffset}
  local test = 0
  for i, value in ipairs(points) do
    table.insert(screenPoints, worldSize * (value / (worldToScreenRatio * zoomAmount) + offsets[(i - 1) % 2 + 1]))
  end
  return screenPoints
end

return transformations
