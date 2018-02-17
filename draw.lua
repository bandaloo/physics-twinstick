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

function draw.worldToScreenPoint(x, y)
  return x / worldToScreenRatio, y / worldToScreenRatio
end

function draw.screenToWorldPoint(x, y)
  return x * worldToScreenRatio, y * worldToScreenRatio
end

function draw.worldToScreenPoints(points)
  local screenPoints = {}
  for i, value in ipairs(points) do
    table.insert(screenPoints, value / worldToScreenRatio)
  end
  return screenPoints
end


function draw.gradientLine(object, layers, center, scalar, fill)
  -- local alpha = selectedAlpha or math.floor(255 / center)
  local fill = fill or 0
  local alpha = math.floor(255 / center)
  local drawFunc
  local params
  if object.drawData == nil then
    love.graphics.setColor(object.color[1], object.color[2], object.color[3], fill)
    if object.shape:getType() == 'circle' then
      drawFunc = love.graphics.circle
      params = {'line', object.body:getX() / worldToScreenRatio, object.body:getY() / worldToScreenRatio, object.shape:getRadius() / worldToScreenRatio}
      if fill > 0 then drawFunc('fill', params[2], params[3], params[4]) end
      --params = {'line', draw.worldToScreenPoint(object.body:getX()), draw.worldToScreenPoint(object.body:getY()), draw.worldToScreenPoint(object.shape:getRadius())}
    elseif object.shape:getType() == 'polygon' then
      drawFunc = love.graphics.polygon
      --params = {'line', draw.worldToScreenPoints(object.shape:getPoints())}
      params = {'line', draw.worldToScreenPoints({object.body:getWorldPoints(object.shape:getPoints())})}
      if fill > 0 then drawFunc('fill', params[2]) end
    elseif object.shape:getType() == 'chain' then
      drawFunc = love.graphics.line
      params = {draw.worldToScreenPoints({object.shape:getPoints()})}
    end
    -- if fill is given draw with fill
  else
    drawFunc = love.graphics.line
    params = draw.worldToScreenPoints(object.drawData)
  end
  love.graphics.setColor(object.color[1], object.color[2], object.color[3], alpha)
  for i = 0, center do
    love.graphics.setLineWidth(scalar * (layers - i) / worldToScreenRatio)
    if i == center then
      love.graphics.setColor(object.color[1], object.color[2], object.color[3], 255)
    end
    drawFunc(unpack(params))
  end
end

return draw
