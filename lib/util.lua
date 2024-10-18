local Util = {}

Util.checkMouseOver = function(x, y, object)
      if object.x and object.y and object.w and object.h then
            if x > object.x and x <= object.x + object.w and y > object.y and y <= object.y + object.h then
                  return true
            end
      end
      return false
end

Util.colorConv = function(tuple)
      if #tuple ~= 3 then
            return { 0, 0, 0 }
      end
      return { tuple[1] / 255, tuple[2] / 255, tuple[3] / 255 }
end

return Util
