local draw = {}

function draw.gradientLine(object, layers, center, scalar)
  local alpha = math.floor(255 / center)
  for i = 0, center do
    if i == center then
      alpha = 255
    end
    love.graphics.setLineWidth(scalar * (layers - i))
    love.graphics.setColor(object.color[1], object.color[2], object.color[3], alpha)
    if object.shape:getType() == 'circle' then
      love.graphics.circle('line', object.body:getX(), object.body:getY(), object.shape:getRadius())
    elseif object.shape:getType() == 'polygon' then
      love.graphics.polygon('line', object.body:getWorldPoints(object.shape:getPoints()))
    elseif object.shape:getType() == 'chain' then
      love.graphics.line(object.shape:getPoints())
    end
  end
end

return draw
