return {
    [1] = function(i, s)
        if s == 1 then
            return 0.05
        else
            return math.sin(i/2) * 10 + 16
        end
    end,
    [2] = function(i, s)
        if s == 1 then
            return 0.07
        else
            return math.cos(i/2) * 10 + 16
        end
    end,
    [3] = function(i, s)
        if s == 1 then
            return 0.2
        else
            i = i/3
            return i*i*i/10 + 16
        end
    end
}