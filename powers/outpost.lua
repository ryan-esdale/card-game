local outpost = {
      type = 'turnStart',
      effect = function()
            local a = require('cards.asteroid'):new()
            a.ethereal = true
            Util.activePlayer().hand:addCard(a)
      end,
      new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            return o
      end,
}

return outpost
