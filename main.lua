function love.load()
   gameState = 0

   player = {}
   player.x = love.graphics:getWidth()/2
   player.y = love.graphics:getHeight() - 70
   player.width = 50
   player.height = 50
   player.speed = 150
   player.bullets = {}

   enemyController = {}
   enemyController.direction = 'r'
   enemyController.speed = 200
   enemyController.accelerationRate = 40
   enemyController.spacing = 60
   enemyController.dropRate = 6
   enemyController.x = 0
   enemyController.y = 0
   enemyController.bulletSpeed = 110
   enemyController.nextBullet = 1
   enemyController.bullets = {}

   enemies = {}

   startGame()
end

function startGame()
   gameState = 1

   enemies = {}
   for i=1, 8 * 3 do makeEnemy()
   end

   enemyController.direction = 'r'
   enemyController.speed = 200
   enemyController.accelerationRate = 40
   enemyController.spacing = 60
   enemyController.dropRate = 6
   enemyController.x = 0
   enemyController.y = 0
   enemyController.bulletSpeed = 110
   enemyController.nextBullet = 1
   enemyController.bullets = {}

   player.x = love.graphics:getWidth()/2
   player.y = love.graphics:getHeight() - 70
   player.width = 50
   player.height = 50
   player.speed = 150
   player.bullets = {}

end


function love.update(dt)
   if gameState == 1 then

      -- stop the game if enemies are gone
      if #enemies <= 0 then
         gameState = 0
      end

      -- Update player
      if love.keyboard.isDown('right') and player.x < love.graphics:getWidth() - player.width then
         player.x = player.x + player.speed * dt
      end

      if love.keyboard.isDown('left') and player.x > 0 then
         player.x = player.x - player.speed * dt
      end

      -- Update bullets
      for i, bullet in ipairs(player.bullets) do
         bullet.y = bullet.y - bullet.speed * dt
         if bullet.y < 0 then bullet.dead = true end
      end

      for i, bullet in ipairs(enemyController.bullets) do
        bullet.y = bullet.y + enemyController.bulletSpeed * dt
        if bullet.y > love.graphics:getHeight() then bullet.dead = true end
      end

      -- update Enemies
      if enemyController.direction == 'r' then
         enemyController.x = enemyController.x + enemyController.speed * dt
      else
         enemyController.x = enemyController.x - enemyController.speed * dt
      end

      -- check colisions
      for i, enemy in ipairs(enemies) do

         -- Switch direction
         if enemyController.x < 0 - enemy.x then 
            -- prevents the enemies from going offscreen
            enemyController.x = 0 - enemy.x 
            enemyController.direction = 'r'
            enemyController.y = enemyController.y + enemyController.dropRate
         end

         if enemyController.x + enemy.x + enemy.width > love.graphics:getWidth() then 
            -- prevents the enemies from going offscreen
            enemyController.x = love.graphics:getWidth() - enemy.x - enemy.width
            enemyController.direction = 'l'
             enemyController.y = enemyController.y + enemyController.dropRate
         end
      end

      -- if enemy is hit
      for i, bullet in ipairs(player.bullets) do
         for j, enemy in ipairs(enemies) do
            if isColliding(bullet, {x = enemy.x + enemyController.x, y = enemy.y + enemyController.y, width = enemy.width, height = enemy.height}) then 
               enemyController.speed = enemyController.speed + enemyController.accelerationRate
               bullet.dead = true
               enemy.dead = true

               enemyController.nextBullet = enemyController.nextBullet - 2
            end
         end
      end

      -- if player is hit
      for i, bullet in ipairs(enemyController.bullets) do
         if isColliding(bullet, player) then
            gameState = 0
         end
      end

      for i, enemy in ipairs(enemies) do
            if isColliding(player, {x = enemy.x + enemyController.x, y = enemy.y + enemyController.y, width = enemy.width, height = enemy.height}) then 
               gameState = 0
            end
      end

      -- clean up the dead
      for i=#player.bullets, 1, -1 do
         local bullet = player.bullets[i]
         if bullet.dead then table.remove(player.bullets, i) end
      end

      for i=#enemyController.bullets, 1, -1 do
         local bullet = enemyController.bullets[i]
         if bullet.dead then table.remove(enemyController.bullets, i) end
      end

      for i=#enemies, 1, -1 do
         local enemy = enemies[i]
         if enemy.dead then table.remove(enemies, i) end
      end

      -- fire bullets
      if enemyController.nextBullet < 0 then
         spawnEnemyBullet()
         local bulletTiming = math.random() * (#enemies * (#enemies / 10)) + .3
         if bulletTiming > 7 then 
            bulletTiming = math.random() * (7 * (#enemies / 10)) + .3
         end
         enemyController.nextBullet = bulletTiming
         print(enemyController.nextBullet)
      else
         enemyController.nextBullet = enemyController.nextBullet - dt
      end
   end
end

function love.draw()
   -- Draw player
   love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)

   -- Draw Bullets
   for i, bullet in ipairs(player.bullets) do
      love.graphics.rectangle('fill', bullet.x, bullet.y, bullet.width, bullet.height)
   end

   for i, bullet in ipairs(enemyController.bullets) do
      love.graphics.rectangle('fill', bullet.x, bullet.y, bullet.width, bullet.height)
   end

   -- Draw Enemies
   for i, enemy in ipairs(enemies) do
      love.graphics.rectangle('fill', enemyController.x + enemy.x, enemyController.y + enemy.y, enemy.width, enemy.height)
   end
end

function love.keypressed(key, scancode, isrepeat)
   if gameState == 1 then
      if key == 'space' or key == 'up' then
         spawnPlayerBullet()
      end
   end

   if gameState == 0 then
      startGame()
   end
end

function makeEnemy() 
   local enemy = {}
   enemy.width = 30
   enemy.height = 25
   enemy.dead = false

   local maxEnemiesPerRow = math.floor(love.graphics:getWidth() / (enemy.width + enemyController.spacing)) 
   local numberOfLoops = math.floor(#enemies / maxEnemiesPerRow)

   enemy.x = (#enemies % maxEnemiesPerRow) * (enemy.width + enemyController.spacing)
   enemy.y = numberOfLoops * 90
   print(#enemies, numberOfLoops, enemy.x, enemy.y)

   table.insert(enemies, enemy)
end

function spawnPlayerBullet() 
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

function spawnEnemyBullet() 
  local bullet = {}
  bullet.width = 4
  bullet.height = 20
  bullet.dead = false

  local chosenEnemy = enemies[math.random(#enemies)]
  bullet.x = enemyController.x + chosenEnemy.x + chosenEnemy.width/2
  bullet.y = enemyController.y + chosenEnemy.y + bullet.height

  table.insert(enemyController.bullets, bullet)
end

function isColliding(a, b)
  if (a.x < b.x + b.width and
      a.x + a.width > b.x and
      a.y < b.y + b.height and
      a.y + a.height > b.y) then
      return true
   else
      return false
   end
end
