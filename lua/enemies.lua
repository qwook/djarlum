
local easing = require "easing"

local function lerp(x1, y1, x2, y2, p)

    if p == 0 then return x1, y1 end
    if p == 1 then return x2, y2 end

    local dist = math.sqrt( math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2) )

    local nx = (x2 - x1) / dist
    local ny = (y2 - y1) / dist

    return x1 + nx * dist * p, y1 + ny * dist * p

end

return {
    -- swirl and go
    [1] = function (self, i)
        local screenHalf = 16
        local radius = 10
        local speed = 0.05
        local quarterAngle = math.pi/2

        local offset1 = 100
        local offset2Length = 100
        local offset2 = offset1 + offset2Length

        local x2, y2 = math.cos(i*speed-quarterAngle)*radius + screenHalf, math.sin(i*speed-quarterAngle)*radius + screenHalf

        if i > offset2 + offset2Length then
            return 33
        elseif i > offset2 then
            local interval = i - offset2
            local p = interval / offset2Length

            return lerp( x2, y2, 16, 33, p )
        elseif i > offset1 then
            return x2, y2
        else
            local interval = i
            local p = interval / offset1

            return lerp( 16, 0, x2, y2, p )
        end
    end
    -- zig zag
    , [1] = function (self, i)
        local screenHalf = 16
        local radius = 8
        local length = 100
        local speed = 0.05
        local interval = i % length
        local p = interval / length

        local goal = math.floor(i / length) % 2

        if goal == 0 then
            return lerp( screenHalf + -radius, i * speed, screenHalf + radius, i * speed, p )
        else
            return lerp( screenHalf + radius, i * speed, screenHalf + -radius, i * speed, p )
        end
    end
    -- seeker
    , [1] = function (self, i, x1, y1)
        if i == 0 then
            self.vx = 0
            self.vy = 0
        end

        local playerX, playerY = playerPos()
        local speed = 0.05
        local damping = 0.25

        local dist = math.sqrt(math.pow(playerY - y1, 2) + math.pow(playerX - x1, 2))
        local nx = (playerX - x1) / dist
        local ny = (playerY - y1) / dist

        local speed = easing.inOutQuint(i, 0, 1, 100) * 2
        if i > 100 then speed = 1 end

        local ax = nx * speed
        local ay = ny * speed

        local halfAng = math.pi / 2
        local ang = math.atan2(playerY - y1, playerX - x1) + halfAng
        local px, py = math.cos(ang), math.sin(ang)
        local throb = math.cos(i * 0.5)*0.1

        if i % 10 == 0 then
            self.vx = self.vx + ax*5
            self.vy = self.vy + ay*5
        end

        self.vx = self.vx * damping + px*throb
        self.vy = self.vy * damping + py*throb

        return x1 + self.vx, y1 + self.vy
    end
    -- heart
    , [1] = function(self, i)
        local offset1 = 100
        local offset2Length = 100
        local offset2 = offset1 + offset2Length

        local interval = (i - offset1) * 0.1
        if i < offset1 then
            interval = 0
        elseif i > offset2 then
            interval = math.pi
        end

        local x = 16*math.pow(math.sin(interval), 3)
        local y = 13*math.cos(interval) - 5*math.cos(2*interval) - 2*math.cos(3*interval) - math.cos(4*interval)
        local x2, y2 = 16 + x*0.5, 16 - y*0.5


        if i > offset2 + offset2Length then
            return 33
        elseif i > offset2 then
            local interval = i - offset2
            local p = interval / offset2Length

            return lerp( x2, y2, 16, 33, p * 2 )
        elseif i > offset1 then
            return x2, y2
        else
            local interval = i
            local p = interval / offset1

            return lerp( 16, 0, x2, y2, p * 2 )
        end
    end
}