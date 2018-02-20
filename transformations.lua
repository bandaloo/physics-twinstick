local transformations = {}

function transformations.worldToScreenScalar(c)
  return c / (worldToScreenRatio * depthScalar) * frameSize
end

function transformations.worldToScreenX(x)
  return (x / (worldToScreenRatio * depthScalar) + xScreenOffset) * frameSize
end

function transformations.worldToScreenY(y)
  return (y / (worldToScreenRatio * depthScalar) + yScreenOffset) * frameSize
end

function transformations.worldToScreenPoint(x, y)
  return transformations.worldToScreenX(x), transformations.worldToScreenY(y)
end

function transformations.screenToWorldPoint(x, y) -- clean this up so the line isn't insanely long
  return (x / frameSize - xScreenOffset) * worldToScreenRatio * depthScalar, (y / frameSize - yScreenOffset) * worldToScreenRatio * depthScalar
end

function transformations.worldToScreenPoints(points)
  local screenPoints = {}
  local offsets = {xScreenOffset, yScreenOffset}
  local test = 0
  for i, value in ipairs(points) do
    table.insert(screenPoints, frameSize * (value / (worldToScreenRatio * depthScalar) + offsets[(i - 1) % 2 + 1]))
  end
  return screenPoints
end

return transformations
