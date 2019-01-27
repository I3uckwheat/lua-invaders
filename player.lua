 local player = {}
 player.x = love.graphics:getWidth()/2
 player.y = love.graphics:getHeight() - 70
 player.width = 50
 player.height = 50
 player.speed = 190
 player.velocity = 0
 player.bullets = {}

function player.reset()
   player.x = love.graphics:getWidth()/2
   player.y = love.graphics:getHeight() - 70
   player.width = 50
   player.height = 50
   player.speed = 150
   player.bullets = {}
end

function player.update(dt)
   -- Update player
   if love.keyboard.isDown('right') and player.velocity < player.speed and player.x < love.graphics:getWidth() - player.width then
      player.velocity = player.velocity + 550 * dt

   elseif love.keyboard.isDown('left') and player.velocity > -player.speed and player.x > 0 then
      player.velocity = player.velocity - 550 * dt
   else 
     if player.velocity > -15 and player.velocity < 15 then
       player.velocity = 0
     elseif player.velocity > 0 then
       player.velocity = player.velocity - 390 * dt
     else
       player.velocity = player.velocity + 390 * dt
     end
   end

   player.x = player.x + player.velocity * dt

   for i, bullet in ipairs(player.bullets) do
      bullet.y = bullet.y - bullet.speed * dt
      if bullet.y < 0 then bullet.dead = true end
   end

   for i=#player.bullets, 1, -1 do
      local bullet = player.bullets[i]
      if bullet.dead then table.remove(player.bullets, i) end
   end
end

function player.draw()
   love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)

   for i, bullet in ipairs(player.bullets) do
      love.graphics.rectangle('fill', bullet.x, bullet.y, bullet.width, bullet.height)
   end
end

function player.fireWeapon() 
   if #player.bullets < 2 then
      local bullet = {}
      bullet.x = player.x
      bullet.y = player.y
      bullet.width = 4
      bullet.height = 14
      bullet.speed = 370
      bullet.dead = false

      table.insert(player.bullets, bullet)
   end
end

return player
