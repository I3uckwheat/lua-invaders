local player = require "player"
local enemyController = require "enemyController"
local explosion = require "explosion"

function love.load()
   gameState = 0
   startGame()
end

function startGame()
   gameState = 1
   enemyController.reset()
   player.reset()
end

function love.update(dt)
   explosion.update(dt)
   if gameState == 1 then

      -- stop the game if enemies are gone
      if #enemyController.enemies <= 0 then
         gameState = 0
      end
      
      -- move stuff
      player.update(dt)
      enemyController.update(dt)

      -- if enemy is hit
      for i, bullet in ipairs(player.bullets) do
         for j, enemy in ipairs(enemyController.enemies) do
            if isColliding(bullet, {x = enemy.x + enemyController.x, y = enemy.y + enemyController.y, width = enemy.width, height = enemy.height}) then 
               bullet.dead = true
               enemy.dead = true
               enemyController.increaseSpeed()
               explosion.spawnExplosion(enemyController.x + enemy.x + enemy.width/2, enemyController.y + enemy.y + enemy.height/2)
            end
         end
      end

      -- if player is hit
      for i, bullet in ipairs(enemyController.bullets) do
         if isColliding(bullet, player) then
            gameState = 0
         end
      end

      -- if enemy hits player
      for i, enemy in ipairs(enemyController.enemies) do
          if isColliding(player, {x = enemy.x + enemyController.x, y = enemy.y + enemyController.y, width = enemy.width, height = enemy.height}) then 
             gameState = 0
          end
      end

      if #enemyController.enemies <= 0 then
         gameState = 0
      end
   end
end

function love.draw()
   player.draw()
   enemyController.draw()
   explosion.draw()
end

function love.keypressed(key, scancode, isrepeat)
   if gameState == 1 then
      if key == 'space' or key == 'up' then
         player.fireWeapon()
      end
   end

   if gameState == 0 then
      startGame()
   end
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
