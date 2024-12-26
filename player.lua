-- local Deck = require('deck')

local Player = {

      playerID = 0,
      buyingPower = 0,
      hand = {},
      -- deck = Deck:new(),
      deck = {},
      discard = {},
      playedCards = {},
      powers = {},
      points = 0,
      new = function(self, id)
            local o = {}
            setmetatable(o, self)
            self.__index = self
            o.playerID = id
            return o
      end,

}

return Player
