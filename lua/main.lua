
local logo = [[
  ########################################################
##      ####    ####  ####    ####  ####  ##  ##  ######  ##
##        ##    ##      ##      ##  ####  ##  ##    ##    ##
##  ####  ####  ##  ##  ##  ##  ##  ####  ##  ##          ##
##  ####  ####  ##      ##    ####    ##      ##  ####    ##
##        ##    ##  ##  ##  ##  ##    ##      ##  ####    ##
  ########################################################
]]

-- this isn't my best code... at all

local enemies = require("enemies")

local canvas = love.graphics.newCanvas(32, 32)
canvas:setFilter('nearest', 'nearest')

local scrW = love.graphics.getWidth()
local scrH = love.graphics.getHeight()


-- heh
function drawString(str, offsetX, offsetY)
    local y = 0
    str:gsub("[^\n]+",
        function(match)
            local data = {}
            for x = 0, match:len()/2-1 do
                if (match:sub(x*2+1, x*2+1) ~= " ") then
                    love.graphics.rectangle('fill', x + offsetX, y + offsetY, 1, 1);
                end
            end
            y = y + 1
        end)
end

local ticks = 0
local state = "menu"

-- player stuff
local lastPlayerX = 0
local lastPlayerY = 0
local playerX = 16
local playerY = 32-4
local playerVelX = 0
local playerVelY = 0
local playerMass = 10
local playerBullets = {}
local nextStopAttack = 0
local nextAttack = 0

-- misc particles
local trail = {}
local nextTrail = 0
local starDust = {}
local nextStarDust = 0

-- enemy stuff
local enemyList = {}
local nextEnemySpawn = 0
local maxEnemySpawn = 3
local enemySpawned = 0
local nextEnemyReload = 0
local enemyType = 0

-- menu state stuff
local menuTransition = 0

function initialize()
    math.randomseed(os.time())
    starDust = {}
    for i = 1, 20 do
        table.insert(starDust, {x=math.floor(math.random(0, 32)), y=math.floor(math.random(0, 32))})
    end
end

function startGame()
    state = "game"

    -- player stuff
    lastPlayerX = 0
    lastPlayerY = 0
    playerX = 16
    playerY = 32-4
    playerVelX = 0
    playerVelY = 0
    playerMass = 10
    playerBullets = {}
    nextStopAttack = 0
    nextAttack = 0

    -- misc particles
    trail = {}
    nextTrail = 0
    nextStarDust = 0

    -- enemy stuff
    enemyList = {}
    nextEnemySpawn = 0
    maxEnemySpawn = 3
    enemySpawned = 0
    nextEnemyReload = 0
    enemyType = 0
end

function love.load()
    initialize()
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(canvas, 0, 0, 0, scrH/32, scrH/32)
end

function draw()
    love.graphics.setCanvas(canvas)
        love.graphics.clear()

        if state == "menu" then
            for i = 1, 20 do
                local col =  i * 4
                love.graphics.setColor(col, col, col)
                local r = (math.cos(ticks/100)+1)/2*255
                local g = (math.sin(ticks/100)+1)/2*255
                local b = ((math.cos(ticks/100)+1)/2) * ((math.cos(ticks/100)+1)/2) * 255
                love.graphics.setColor(col, col, col)
                love.graphics.setColor((r + i*4)*0.25, (g + i*4)*0.25, (b + i*4)*0.25)
                love.graphics.circle('fill', playerX, playerY, (20-i+1)*6, (20-i+1)*12)
            end

            -- draw fucking stars
            for i, v in pairs(starDust) do
                love.graphics.setColor(255, 255, 255, (math.cos(ticks/20 + v.x + v.y)+1)/2 * 100+5)
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end

            -- logo!
            if menuTransition > 0 then
                love.graphics.setColor(0, 0, 0, 100 * (1-menuTransition))
                drawString(logo, 1, 5)
                love.graphics.setColor(255, 255, 255, 200 * (1-menuTransition))
                drawString(logo, 1, 4)
            else
                love.graphics.setColor(0, 0, 0, 100)
                drawString(logo, 1, 5)
                love.graphics.setColor(255, 255, 255, 200)
                drawString(logo, 1, 4)
            end
        elseif state == "game" then
            for i, v in pairs(trail) do
                local col =  i * 4
                love.graphics.setColor(col, col, col)
                local r = (math.cos(ticks/100)+1)/2*255
                local g = (math.sin(ticks/100)+1)/2*255
                local b = ((math.cos(ticks/100)+1)/2) * ((math.cos(ticks/100)+1)/2) * 255
                love.graphics.setColor(col, col, col)
                love.graphics.setColor((r + i*4)*0.25, (g + i*4)*0.25, (b + i*4)*0.25)
                love.graphics.setColor((r + i*4), (g + i*4), (b + i*4))
                love.graphics.circle('fill', v.x, v.y, (#trail-i+1)*6, (#trail-i+1)*12)
            end

            -- draw fucking stars
            for i, v in pairs(starDust) do
                love.graphics.setColor(255, 255, 255, 5)
                love.graphics.rectangle('fill', v.x, v.y-3, 1, 3)
                love.graphics.setColor(255, 255, 255, 50)
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end

            love.graphics.setColor(255, 255, 255, 10)
            love.graphics.rectangle('fill', lastPlayerX, lastPlayerY, 1, 1)
            love.graphics.setColor(255, 255, 255)
            love.graphics.rectangle('fill', playerX, playerY, 1, 1)

            -- firing, draw muzzleflash
            if (love.keyboard.isDown(" ")) then
                local a = (math.cos(ticks)+1)/2*255
                if a < 100 then a = 0 end
                love.graphics.setColor(255, 255, 0, a*0.5)
                love.graphics.rectangle('fill', playerX-1, playerY-1, 3, 1)
                love.graphics.setColor(255, 255, 255, a)
                love.graphics.rectangle('fill', playerX, playerY-1, 1, 1)
                love.graphics.setColor(255, 255, 0, a*0.25)
                love.graphics.circle('fill', playerX, playerY, 10, 20)
            end

            -- draw bullet
            for k, v in pairs(playerBullets) do
                local col = math.floor((math.cos(ticks-v.id)+1)/2*4)
                if (col == 0) then
                    love.graphics.setColor(255, 255, 255)
                elseif (col == 1) then
                    love.graphics.setColor(255, 0, 0, 100)
                elseif (col == 3) then
                    love.graphics.setColor(255, 255, 0, 100)
                else
                    love.graphics.setColor(0, 0, 255, 100)
                end
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end

            -- draw enemies (EVIL!)
            love.graphics.setColor(255, 255, 255, 255)
            -- love.graphics.setBlendMode('subtractive')
            for k, v in pairs(enemyList) do
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end
            -- love.graphics.setBlendMode('alpha')

            love.graphics.setColor(255, 255, 255, 100)
            -- drawEnemy(enemies[3])
        end

    love.graphics.setCanvas()
end

local rate = 1 / 60
local time = 0
function love.update(dt)
    time = time + dt
    if time > rate then
        for i = 1, math.floor(time / rate) do
            tick()
        end
        time = time - (math.floor(time / rate) * rate)
        draw()
    end
end

function tick()
    ticks = ticks + 1


    if state == "menu" then
        if (love.keyboard.isDown(" ")) and menuTransition == 0 then
            menuTransition = 0.01
        end

        if (menuTransition > 0) then

            -- fucking sparkles
            if (ticks > nextStarDust) then
                table.insert(starDust, {x=math.floor(math.random(0, 32)),y=0})
                if (#starDust > 5) then
                    table.remove(starDust, 1)
                end
                nextStarDust = ticks + 10
            end
            for k, v in pairs(starDust) do
                v.y = v.y + menuTransition
            end

            menuTransition = menuTransition + 0.01
        end

        if (menuTransition > 1) then
            startGame()
        end
    elseif state == "game" then
        local forceX = 0
        local forceY = 0
        local velocity = math.sqrt(playerVelX*playerVelX+playerVelY*playerVelY)
        if velocity ~= velocity then
            velocity = 0
        end

        if (love.keyboard.isDown("left")) then
            forceX = forceX - 1
        elseif (love.keyboard.isDown("right")) then
            forceX = forceX + 1
        end
        if (love.keyboard.isDown("up")) then
            forceY = forceY - 1
        elseif (love.keyboard.isDown("down")) then
            forceY = forceY + 1
        end

        local force = math.sqrt(forceX*forceX+forceY*forceY)
        if force ~= force then
            force = 0
        end

        if (force > 0) then
            local nX = forceX / force
            local nY = forceY / force

            playerVelX = playerVelX + nX/playerMass*0.5
            playerVelY = playerVelY + nY/playerMass*0.5
        end

        -- drag
        if velocity > 0 then
            local rho = 1.2 -- density of air
            local cd = 0.5
            local drag = 0.5*rho*velocity*velocity*cd

            local nVelX = playerVelX / velocity
            local nVelY = playerVelY / velocity

            playerVelX = playerVelX - nVelX*drag
            playerVelY = playerVelY - nVelY*drag
        end

        playerX = playerX + playerVelX
        playerY = playerY + playerVelY

        if playerX < 0 then
            playerX = 0
        elseif playerX >= 31 then
            playerX = 31
        end
        if playerY < 0 then
            playerY = 0
        elseif playerY > 31 then
            playerY = 31
        end

        if ticks > nextTrail then
            table.insert(trail, {x=playerX, y=playerY})
            if (#trail > 10) then
                table.remove(trail, 1)
            end

            lastPlayerX = playerX
            lastPlayerY = playerY

            nextTrail = ticks + 5
        end

        -- shoot
        if (love.keyboard.isDown(" ")) then
            if ticks > nextAttack then
                table.insert(playerBullets, {x=playerX, y=playerY, id=ticks})
                nextAttack = ticks + 10
            end
        end

        -- spawn enemies
        if enemySpawned >= maxEnemySpawn then
            if ticks > nextEnemyReload then
                enemySpawned = 0
                nextEnemySpawn = 0
                enemyType = (enemyType + 1) % #enemies
            end
        else
            local fn = enemies[enemyType + 1]
            if ticks > nextEnemySpawn then
                table.insert(enemyList, {x=fn(0), y=0, fn=fn, dead=false})
                enemySpawned = enemySpawned + 1
                nextEnemySpawn = ticks + 10
                nextEnemyReload = ticks + 100
            end
        end

        -- manage bullets
        local deadBullets = {}
        for k, v in pairs(playerBullets) do
            v.y = v.y - 1

            for _k, _v in pairs(enemyList) do
                if math.floor(math.pow(v.x-_v.x, 2) + math.pow(v.y-_v.y, 2)) < 2 and _v.dead ~= true then
                    _v.dead = true
                    table.insert(deadBullets, v)
                    break
                end
            end

            if v.y < 0 then
                table.insert(deadBullets, v)
            end
        end

        -- clean up dead bullets
        local i = 0
        while (deadBullets[1] ~= nil and playerBullets[i] ~= deadBullets[1]) do
            i = i + 1
            if (playerBullets[i] == deadBullets[1]) then
                table.remove(playerBullets, i)
                table.remove(deadBullets, 1)
                i = i - 1
            end
        end

        -- manage enemies
        local deadEnemies = {}
        for k, v in pairs(enemyList) do
            local speed = v.fn(0, 1)
            v.y = v.y + speed
            if v.y > 32 or v.dead == true then
                table.insert(deadEnemies, v)
            else
                v.x = v.fn(v.y)
            end
        end

        -- clean up dead enemies
        local i = 0
        while (deadEnemies[1] ~= nil and enemyList[i] ~= deadEnemies[1]) do
            i = i + 1
            if (enemyList[i] == deadEnemies[1]) then
                table.remove(enemyList, i)
                table.remove(deadEnemies, 1)
                i = i - 1
            end
        end

        -- fucking sparkles
        if (ticks > nextStarDust) then
            table.insert(starDust, {x=math.floor(math.random(0, 32)),y=0})
            if (#starDust > 5) then
                table.remove(starDust, 1)
            end
            nextStarDust = ticks + 5
        end
        for k, v in pairs(starDust) do
            v.y = v.y + 1
        end
    end
end

function love.keypressed(key, isrepeat)
end

function love.keyreleased(key)
end

function drawEnemy(enemy)
    local points = {}
    for y = 1, 32 do
        local x = enemy(y)
        table.insert(points, x)
        table.insert(points, y)
    end
    love.graphics.line(points)
end
