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

return helpers
