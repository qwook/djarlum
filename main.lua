local _require = require
function require(path)
    if path:sub(1, 2) == ".." then
        return error("Cannot access outside of lua folder!")
    else
        return _require("lua." .. path)
    end
end
require("main")