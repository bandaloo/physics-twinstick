local helpers = {}

function helpers.distance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

function helpers.normalize(x, y)
  local magnitude = distance(0, 0, x, y);
  return x / magnitude, y / magnitude
end

function helpers.normalToPoint(x1, y1, x2, y2)
  local magnitude = helpers.distance(x1, y1, x2, y2)
  return (x2 - x1) / magnitude, (y2 - y1) / magnitude
end

function helpers.circleSectionPoints(x, y, radius, sections, angleStart, angleEnd)
  local points = {}
  local step = (angleEnd - angleStart) / (sections - 1)
  for i = angleStart, angleEnd, step do
    table.insert(points, x + radius * math.cos(i))
    table.insert(points, y + radius * math.sin(i))
  end
  return points
end

function helpers.combine(...)
  local combined = {}
  for i, itable in ipairs({...}) do
    for j, value in ipairs(itable) do
      table.insert(combined, value)
    end
  end
  return combined
end

return helpers
