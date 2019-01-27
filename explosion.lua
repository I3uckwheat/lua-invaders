local explosion = {}
local explosions = {}

function explosion.spawnExplosion(x, y) 
  for i=8, 1, -1 do 
     table.insert(explosions, {
       x = x,
       y = y,
       dx = math.random(400) - 200,
       dy = math.random(400) - 200,
       l = math.random() * .4,
       t = 0,
       dead = false
     })
  end
end

function explosion.draw() 
   for i,p in ipairs(explosions) do
      love.graphics.setColor(29, 43, 83)
      love.graphics.rectangle("fill", p.x, p.y, 4, 4)
   end
end

function explosion.update(dt) 
  for i,p in ipairs(explosions) do
     p.x = p.x + p.dx * dt
     p.y = p.y + p.dy * dt
     p.dy = p.dy + 90 * dt
     p.t = p.t + 1 * dt
     p.l = p.l - 1 * dt

     if p.l < 0 then p.dead = true end
     if p.t > 2.5 then p.dead = true end
  end

  for i=#explosions, 1, -1 do
     local p = explosions[i]

     if p.dead or
        p.x > love.graphics:getWidth() or
        p.y > love.graphics:getHeight() or
        p.x < 0 or
        p.y < 0 then
        table.remove(explosions, i)
     end
  end
end

return explosion
