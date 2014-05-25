return {
    -- [1] = function(i, s)
    --     if s == 1 then
    --         return 0.05
    --     else
    --         return i, math.sin(i/2) * 10 + 16
    --     end
    -- end,
    -- [2] = function(i, s)
    --     if s == 1 then
    --         return 0.07
    --     else
    --         return math.sin(i/2) * 10 + 16, math.cos(i/2) * 10 + 16
    --     end
    -- end,
    -- [3] = function(i, s)
    --     if s == 1 then
    --         return 0.2
    --     else
    --         i = i/3
    --         return i, i*i*i/10 + 16
    --     end
    -- end
    [1] = function (i, s)
        if i > 100 then
            return math.cos(i*0.01)*10 + 16, math.sin(i*0.01)*10 + 16
        else
            return 16, i/100*16
        end
    end
}