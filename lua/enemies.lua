
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

        local offsetX = self.variation

        local offset1 = 100
        local offset2Length = 100
        local offset2 = offset1 + offset2Length

        local x2, y2 = math.cos(i*speed-quarterAngle)*radius + offsetX, math.sin(i*speed-quarterAngle)*radius + screenHalf

        if i > offset2 + offset2Length then
            return 33
        elseif i > offset2 then
            local interval = i - offset2
            local p = interval / offset2Length

            return lerp( x2, y2, offsetX, 33, p )
        elseif i > offset1 then
            return x2, y2
        else
            local interval = i
            local p = interval / offset1

            return lerp( offsetX, 0, x2, y2, p )
        end
    end
    -- zig zag
    , [2] = function (self, i)

        local screenHalf = 16
        local radius = 8
        local length = 100
        local speed = 0.05
        local interval = i % length
        local p = interval / length

        local offset = (self.variation / 32 * (32 - radius*2)) + radius

        local goal = math.floor(i / length) % 2

        if goal == 0 then
            return lerp( offset + -radius, i * speed, offset + radius, i * speed, p )
        else
            return lerp( offset + radius, i * speed, offset + -radius, i * speed, p )
        end
    end
    -- seeker
    , [3] = function (self, i, x1, y1)

        local offset = self.variation

        if i == 0 then
            self.x = offset
            x1 = offset
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
    , [4] = function(self, i)

        local enterLength = 50
        local heartLength = 100
        local exitLength = 50

        local offset = self.variation

        if i < enterLength then
            local p = i / enterLength

            local x = 16*math.pow(math.sin(0), 3)
            local y = 13*math.cos(0) - 5*math.cos(2*0) - 2*math.cos(3*0) - math.cos(4*0)
            local x2, y2 = 16 + x*0.5 + offset - 16, 16 - y*0.5

            return lerp(offset, 0, x2, y2, p)
        elseif i < enterLength + heartLength then
            local p = (i - enterLength) / heartLength

            local ang = p*math.pi*2
            local x = 16*math.pow(math.sin(ang), 3)
            local y = 13*math.cos(ang) - 5*math.cos(2*ang) - 2*math.cos(3*ang) - math.cos(4*ang)
            local x2, y2 = 16 + x*0.5 + offset - 16, 16 - y*0.5

            return x2, y2
        elseif i < enterLength + heartLength + exitLength then
            local p = (i - enterLength - heartLength) / enterLength

            local ang = 1*math.pi*2
            local x = 16*math.pow(math.sin(ang), 3)
            local y = 13*math.cos(ang) - 5*math.cos(2*ang) - 2*math.cos(3*ang) - math.cos(4*ang)
            local x2, y2 = 16 + x*0.5 + offset - 16, 16 - y*0.5

            return lerp(x2, y2, offset, 32, p)
        else
            return 0, 33
        end

    end
}