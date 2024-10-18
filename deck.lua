local Cards = require('loadCards')
-- Deck
local Deck = {
      graphic = Cards['testCard']:new(),
      cards = {},
      addCard = function(self, card, count)
            for i = 1, count or 1, 1 do
                  local tempCard = Cards[card]:new()
                  table.insert(self.cards, tempCard)
                  io.write("Added a " .. tempCard.title .. " card to deck.\n")
            end
      end,
      new = function(self)
            local o = {}
            setmetatable(o, self)
            self.__index = self
            return o
      end,
}


return Deck
