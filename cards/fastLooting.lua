local CardTemplate = require('cards.template')

local greenCard = CardTemplate:new()


-- Green that costs 2 and draws 4
greenCard.title = "Green Card"
greenCard.text = "Discard 2 cards \nDraw 4 cards."
greenCard.color = { 0, 1, 0 }
greenCard.cost = 2
greenCard.play = function(self)
      Game.discardCallback = function()
            Hand:drawCard(4)
      end

      CardTemplate.play(self)
end

return greenCard
