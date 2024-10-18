local CardTemplate = require('cards.template')

local greenCard = CardTemplate:new()


-- Green that costs 2 and draws 4
greenCard.title = "Green Card"
greenCard.text = "Draw 4 cards."
greenCard.color = { 0, 1, 0 }
greenCard.buyCost = 4
greenCard.playCost = 2
greenCard.play = function(self)
      Game.discardCallback = function()
            Game.players[Game.activePlayer].hand:drawCard(4)
      end

      CardTemplate.play(self)
end

return greenCard
