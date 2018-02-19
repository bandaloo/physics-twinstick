local t = require "transformations"

local draw = {}

-- function draw.gradientLine(object, layers, center, scalar)
--   local alpha = math.floor(255 / center)
--   for i = 0, center do
--     if i == center then
--       alpha = 255
--     end
--     love.graphics.setLineWidth(scalar * (layers - i))
--     love.graphics.setColor(object.color[1], object.color[2], object.color[3], alpha)
--     if object.shape:getType() == 'circle' then
--       love.graphics.circle('line', object.body:getX(), object.body:getY(), object.shape:getRadius())
--     elseif object.shape:getType() == 'polygon' then
--       love.graphics.polygon('line', object.body:getWorldPoints(object.shape:getPoints()))
--     elseif object.shape:getType() == 'chain' then
--       love.graphics.line(object.shape:getPoints())
--     end
--   end
-- end

-- all these transformations should be in a different module; i was being lazy
-- function draw.worldToScreenScalar(c)
--   return c / (worldToScreenRatio * zoomAmount)
-- end
--
-- function draw.worldToScreenX(x)
--   return x / (worldToScreenRatio * zoomAmount) + xScreenOffset
-- end
--
-- function draw.worldToScreenY(y)
--   return y / (worldToScreenRatio * zoomAmount) + yScreenOffset
-- end
--
-- function draw.worldToScreenPoint(x, y)
--   return draw.worldToScreenX(x), draw.worldToScreenY(y)
-- end
--
-- function draw.screenToWorldPoint(x, y)
--   return (x - xScreenOffset) * worldToScreenRatio * zoomAmount, (y - yScreenOffset) * worldToScreenRatio * zoomAmount
-- end

-- function draw.worldToScreenPoints(points)
--   local screenPoints = {}
--   local offsets = {xScreenOffset, yScreenOffset}
--   local test = 0
--   for i, value in ipairs(points) do
--     table.insert(screenPoints, value / (worldToScreenRatio * zoomAmount) + offsets[(i - 1) % 2 + 1])
--   end
--   return screenPoints
-- end


-- function draw.gradientLine(object, layers, center, scalar, fill)
--   -- local alpha = selectedAlpha or math.floor(255 / center)
--   local fill = fill or 0
--   local alpha = math.floor(255 / center)
--   local drawFunc
--   local params
--   if object.drawData == nil then
--     love.graphics.setColor(object.color[1], object.color[2], object.color[3], fill)
--     if object.shape:getType() == 'circle' then
--       drawFunc = love.graphics.circle
--       params = {'line', t.worldToScreenX(object.body:getX()), t.worldToScreenY(object.body:getY()), t.worldToScreenScalar(object.shape:getRadius())}
--       if fill > 0 then drawFunc('fill', params[2], params[3], params[4]) end
--       --params = {'line', t.worldToScreenPoint(object.body:getX()), t.worldToScreenPoint(object.body:getY()), t.worldToScreenPoint(object.shape:getRadius())}
--     elseif object.shape:getType() == 'polygon' then
--       drawFunc = love.graphics.polygon
--       --params = {'line', t.worldToScreenPoints(object.shape:getPoints())}
--       params = {'line', t.worldToScreenPoints({object.body:getWorldPoints(object.shape:getPoints())})}
--       if fill > 0 then drawFunc('fill', params[2]) end
--     elseif object.shape:getType() == 'chain' then
--       drawFunc = love.graphics.line
--       params = {t.worldToScreenPoints({object.shape:getPoints()})} -- do we need the outside brackets?
--     end
--   else
--     drawFunc = object.drawFunc
--     params = object.drawData
--   end
--   love.graphics.setColor(object.color[1], object.color[2], object.color[3], alpha)
--   for i = 0, center do
--     love.graphics.setLineWidth(scalar * (layers - i) / (worldToScreenRatio * zoomAmount))
--     if i == center then
--       love.graphics.setColor(object.color[1], object.color[2], object.color[3], 255)
--     end
--     drawFunc(unpack(params))
--   end
-- end

function draw.objectData(object)
  local drawFunc
  local params
  local data = {}
  data.color = {object.color[1], object.color[2], object.color[3]}
  data.type = object.shape:getType()
  if data.type == 'circle' then
    data.x = object.body:getX()
    data.y = object.body:getY()
    data.radius = object.shape:getRadius()
  elseif data.type == 'polygon' then
    data.points = {object.body:getWorldPoints(object.shape:getPoints())}
  elseif data.type == 'chain' then
    data.points = {object.shape:getPoints()}
  end
  return data
end

function draw.gradientLine(data, layers, center, scalar, fill)
  local fill = fill or 0
  local alpha = math.floor(255 / center)
  local drawFunc
  local params
  love.graphics.setColor(data.color[1], data.color[2], data.color[3], fill)
  if data.type == 'circle' then
    drawFunc = love.graphics.circle
    params = {'line', t.worldToScreenX(data.x), t.worldToScreenY(data.y), t.worldToScreenScalar(data.radius)}
    if fill > 0 then drawFunc('fill', params[2], params[3], params[4]) end
  elseif data.type == 'polygon' then
    drawFunc = love.graphics.polygon
    params = {'line', t.worldToScreenPoints(data.points)}
    if fill > 0 then drawFunc('fill', params[2]) end
  elseif data.type == 'chain' then
    drawFunc = love.graphics.line
    params = {t.worldToScreenPoints(data.points)} -- do we need the outside brackets?
  end
  love.graphics.setColor(data.color[1], data.color[2], data.color[3], alpha)
  for i = 0, center do
    love.graphics.setLineWidth(scalar * (layers - i) / (worldToScreenRatio * zoomAmount * (1 / worldSize)))
    if i == center then
      love.graphics.setColor(data.color[1], data.color[2], data.color[3], 255)
    end
    drawFunc(unpack(params))
  end
end

return draw
