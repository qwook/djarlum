
local logo = [[
############################################################
##      ####    ####  ####    ####  ####  ##  ##  ######  ##
##        ##    ##      ##      ##  ####  ##  ##    ##    ##
##  ####  ####  ##  ##  ##  ##  ##  ####  ##  ##          ##
##  ####  ####  ##      ##    ####    ##      ##  ####    ##
##        ##    ##  ##  ##  ##  ##    ##      ##  ####    ##
############################################################
]]

-- this isn't my best code... at all

local enemies = require("enemies")
local gameovertext = require("gameover")
local font = require("font")

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

function printString(str, x, y)
    str = tostring(str)
    for i = 1, str:len() do
        local char = str:sub(i, i)
        local id = tonumber(char)
        drawString(font[id], x + (i-1) * 4, y)
    end
end

local ticks = 0
local state = "menu"

local timelapse = 0
local dead = -1

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
local score = 0

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
local enemyReloadTime = 100
local enemyType = 0
local variation = math.random(0, 32)

local deadEnemies = {}
local deadBullets = {}

-- menu state stuff
local menuTransition = 0

function playerPos()
    return playerX, playerY
end

function initialize()
    math.randomseed(os.time())
    starDust = {}
    for i = 1, 20 do
        table.insert(starDust, {x=math.floor(math.random(0, 32)), y=math.floor(math.random(0, 32))})
    end
end

function startGame()
    state = "menu"

    timelapse = 0
    dead = -1

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
    score = 0

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
    variation = math.random(0, 32)
end

function love.load()
    initialize()
    startGame()
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(canvas, 0, 0, 0, scrH/32, scrH/32)
end

local function lerp (a, b, t)
        return a + (b - a) * t
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
            -- draw trail
            -- when dead
            if dead > -1 then
                for i, v in pairs(trail) do
                    local r = (math.cos(ticks/100)+1)/2*255
                    local g = (math.sin(ticks/100)+1)/2*255
                    local b = ((math.cos(ticks/100)+1)/2) * ((math.cos(ticks/100)+1)/2) * 255
                    r = math.min(r + i*25 - 100, 255)
                    g = math.min(g + i*25 - 100, 255)
                    b = math.min(b + i*25 - 100, 255)
                    r = math.min(255, r + dead*4)
                    g = math.max(0, g - dead*4)
                    b = math.max(0, b - dead*4)
                    love.graphics.setColor(r, g, b)

                    local red = #trail - math.floor(dead / 10)
                    if i > red then
                        love.graphics.setColor(255, 0, 0)
                    end

                    local timeoffset = (ticks / 10 % 6) - 6
                    love.graphics.circle('fill', v.x, v.y, (#trail-i+1)*6+timeoffset, (#trail-i+1)*12+timeoffset)
                end
            -- when alive
            else
                for i, v in pairs(trail) do
                    local r = (math.cos(ticks/100)+1)/2*255
                    local g = (math.sin(ticks/100)+1)/2*255
                    local b = ((math.cos(ticks/100)+1)/2) * ((math.cos(ticks/100)+1)/2) * 255
                    r = math.min(r + i*25 - 100, 255)
                    g = math.min(g + i*25 - 100, 255)
                    b = math.min(b + i*25 - 100, 255)
                    love.graphics.setColor(r, g, b)
                    local timeoffset = (ticks / 10 % 6) - 6
                    love.graphics.circle('fill', v.x, v.y, (#trail-i+1)*6+timeoffset, (#trail-i+1)*12+timeoffset)
                end
            end

            -- draw fucking stars
            for i, v in pairs(starDust) do
                love.graphics.setColor(255, 255, 255, 5)
                love.graphics.rectangle('fill', v.x, v.y-3, 1, 3)
                love.graphics.setColor(255, 255, 255, 50)
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end

            -- draw player
            love.graphics.setColor(255, 255, 255, 10)
            love.graphics.rectangle('fill', lastPlayerX, lastPlayerY, 1, 1)
            -- love.graphics.setColor(255, 255, 255)
            local r = (math.cos(ticks/100)+1)/2*255
            local g = (math.sin(ticks/100)+1)/2*255
            local b = ((math.cos(ticks/100)+1)/2) * ((math.cos(ticks/100)+1)/2) * 255
            love.graphics.setColor(255 - math.min(r + #trail*25 - 100, 255), 255 - math.min(g + #trail*25 - 100, 255), 255 - math.min(b + #trail*25 - 100, 255))
            love.graphics.rectangle('fill', playerX, playerY, 1, 1)

            -- firing, draw muzzleflash
            -- if (love.keyboard.isDown(" ")) then
            --     local a = (math.cos(ticks)+1)/2*255
            --     if a < 100 then a = 0 end
            --     love.graphics.setColor(255, 255, 0, a*0.5)
            --     love.graphics.rectangle('fill', playerX-1, playerY-1, 3, 1)
            --     love.graphics.setColor(255, 255, 255, a)
            --     love.graphics.rectangle('fill', playerX, playerY-1, 1, 1)
            --     love.graphics.setColor(255, 255, 0, a*0.25)
            --     love.graphics.circle('fill', playerX, playerY, 10, 20)
            -- end

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
            love.graphics.setColor(255, (math.cos(ticks/2) + 1) * 100, 0, 255)
            -- love.graphics.setColor(255, 200, 0, 255)
            -- love.graphics.setBlendMode('subtractive')
            for k, v in pairs(enemyList) do
                love.graphics.rectangle('fill', v.x, v.y, 1, 1)
            end
            -- love.graphics.setBlendMode('alpha')

            love.graphics.setColor(255, 255, 255, 100)
            -- drawEnemy(enemies[3])

            -- draw score
            love.graphics.setColor(0, 0, 0, 10)
            -- printString(score, 0, 0)
            -- printString(score, 2, 2)
            -- printString(score, 0, 2)
            -- printString(score, 2, 0)
            printString(score, 1, 2)
            printString(score, 2, 1)
            printString(score, 1, 0)
            printString(score, 0, 1)
            love.graphics.setColor(255, 255, 255)
            printString(score, 1, 1)

            if dead > -1 and (math.floor(ticks/30) % 2 == 0) then
                love.graphics.setColor(0, 0, 0)
                drawString(gameovertext, 0, 13)
            end
        end

    love.graphics.setCanvas()
end

local rate = 1 / 60
local time = 0
function love.update(dt)
    time = time + dt
    if time > rate then
        for i = 1, math.min(math.floor(time / rate), 5) do
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

        timelapse = timelapse + 1

        local forceX = 0
        local forceY = 0
        local velocity = math.sqrt(playerVelX*playerVelX+playerVelY*playerVelY)
        if velocity ~= velocity then
            velocity = 0
        end

        if dead == -1 then
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
                table.insert(playerBullets, {x=playerX, y=playerY-1, id=ticks})
                nextAttack = ticks + 15
            end
        end

        -- if #enemyList <= 6 then
            -- spawn enemies
            if enemySpawned >= maxEnemySpawn then
                if ticks > nextEnemyReload then
                    enemySpawned = 0
                    nextEnemySpawn = 0
                    enemyType = (enemyType + 1) % #enemies
                    variation = math.random(0, 32)
                end
            else
                local fn = enemies[enemyType + 1]
                if ticks > nextEnemySpawn then
                    local obj = {x=0, y=0, i=0, fn=fn, variation = variation, dead=false}
                    local x, y = fn(obj, 0, 0, 0)
                    obj.x = x
                    obj.y = y
                    table.insert(enemyList, obj)
                    enemySpawned = enemySpawned + 1
                    nextEnemySpawn = ticks + 10
                    nextEnemyReload = ticks + enemyReloadTime
                end
            end
        -- end

        -- manage bullets
        for k, v in pairs(playerBullets) do
            v.y = v.y - 1

            for _k, _v in pairs(enemyList) do
                if math.floor(math.pow(v.x-_v.x, 2) + math.pow(v.y-_v.y, 2)) < 2 and _v.dead ~= true then
                    _v.dead = true
                    table.insert(deadBullets, v)
                    score = score + 1
                    break
                end
            end

            if v.y < 0 then
                table.insert(deadBullets, v)
            end
        end

        -- clean up dead bullets
        local i = 1
        while (i <= #playerBullets) do
            for k, deadBullet in pairs(deadBullets) do
                if (playerBullets[i] == deadBullet) then
                    table.remove(playerBullets, i)
                    table.remove(deadBullets, k)
                    i = i - 1
                    break
                end
            end
            i = i + 1
        end


        -- manage enemies
        for k, v in pairs(enemyList) do
            v.i = v.i + 1
            if v.y > 32 or v.dead == true then
                table.insert(deadEnemies, v)
            else
                v.x, v.y = v.fn(v, v.i, v.x, v.y)
            end

            -- check to see if we're touching the player
            if math.sqrt(math.pow(v.x - playerX, 2) + math.pow(v.y - playerY, 2)) < 1 then
                gameover()
            end
        end

        -- clean up dead enemies
        local i = 1
        while (i <= #enemyList) do
            for k, deadEnemy in pairs(deadEnemies) do
                if (enemyList[i] == deadEnemy) then
                    table.remove(enemyList, i)
                    table.remove(deadEnemies, k)
                    i = i - 1
                    break
                end
            end
            i = i + 1
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

        if timelapse % 1000 == 0 then
            enemyReloadTime = math.min( 25, 100 - math.pow(timelapse/1000, 3) )
            maxEnemySpawn = math.max( 6, math.floor(3 + timelapse/1000) )
        end
    end

    if state == "game" and dead > -1 then
        dead = dead + 1

        -- restart game
        if (not lastSpace and love.keyboard.isDown(" ")) then
            state = "menu"
            menuTransition = 0.01
        end
    end

    lastSpace = love.keyboard.isDown(" ")
end

function gameover()
    -- state = "menu"
    -- menuTransition = 0
    if dead == -1 then
        dead = 0
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
