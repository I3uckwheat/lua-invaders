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

enemyController.totalEnemies = 16
enemyController.enemies = {}


function enemyController.reset()
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
   enemyController.enemies = {}
   enemyController.totalEnemies = 16

   -- spawn Enemies
   for i=1, enemyController.totalEnemies do enemyController.makeEnemy() end
end

function enemyController.update(dt)
   -- update bullets
   for i, bullet in ipairs(enemyController.bullets) do
     bullet.y = bullet.y + enemyController.bulletSpeed * dt
     if bullet.y > love.graphics:getHeight() then bullet.dead = true end
   end

   -- update enemies position
   if enemyController.direction == 'r' then
      enemyController.x = enemyController.x + enemyController.speed * dt
   else
      enemyController.x = enemyController.x - enemyController.speed * dt
   end

   -- check colisions
   for i, enemy in ipairs(enemyController.enemies) do
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

   -- fire enemy bullets
   if enemyController.nextBullet < 0 then
      enemyController.spawnEnemyBullet()
      local bulletTiming = (1 - (enemyController.totalEnemies - #enemyController.enemies) / enemyController.totalEnemies) * (math.random() * 4)
      -- enemyController.nextBullet = bulletTiming
      enemyController.nextBullet = bulletTiming
   else
      enemyController.nextBullet = enemyController.nextBullet - dt
   end

   --[[ Clean up the dead ]]
   -- remove dead bullets
   for i=#enemyController.bullets, 1, -1 do
      local bullet = enemyController.bullets[i]
      if bullet.dead then table.remove(enemyController.bullets, i) end
   end
   -- remove dead enemies
   for i=#enemyController.enemies, 1, -1 do
      local enemy = enemyController.enemies[i]
      if enemy.dead then table.remove(enemyController.enemies, i) end
   end
end

function enemyController.draw()
   -- draw bullets
   for i, bullet in ipairs(enemyController.bullets) do
      love.graphics.rectangle('fill', bullet.x, bullet.y, bullet.width, bullet.height)
   end

   -- Draw Enemies
   for i, enemy in ipairs(enemyController.enemies) do
      love.graphics.rectangle('fill', enemyController.x + enemy.x, enemyController.y + enemy.y, enemy.width, enemy.height)
   end
end

function enemyController.makeEnemy() 
   local enemy = {}
   enemy.width = 30
   enemy.height = 25
   enemy.dead = false

   local maxEnemiesPerRow = math.floor(love.graphics:getWidth() / (enemy.width + enemyController.spacing)) 
   local numberOfLoops = math.floor(#enemyController.enemies / maxEnemiesPerRow)

   enemy.x = (#enemyController.enemies % maxEnemiesPerRow) * (enemy.width + enemyController.spacing)
   enemy.y = numberOfLoops * 90

   table.insert(enemyController.enemies, enemy)
end

function enemyController.spawnEnemyBullet() 
  local chosenEnemy = enemyController.enemies[math.random(#enemyController.enemies)]

  if chosenEnemy then
    local bullet = {}
    bullet.width = 4
    bullet.height = 20
    bullet.dead = false

    bullet.x = enemyController.x + chosenEnemy.x + chosenEnemy.width/2
    bullet.y = enemyController.y + chosenEnemy.y + bullet.height

    table.insert(enemyController.bullets, bullet)
  end
end

function enemyController.increaseSpeed()
   enemyController.speed = enemyController.speed + enemyController.accelerationRate
end

return enemyController
