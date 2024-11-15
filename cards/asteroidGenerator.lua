local CardTemplate = require('cards.template')

local card = CardTemplate:new()

card.title = "Asteroid Catcher"
card.text = "At the start of each turn add an asteroid to your hand."
card.color = Util.colorConv({ 200, 75, 210 })
card.buyCost = 3
card.playCost = 3
card.power = true
card.play = function(self)
      Game.discardCallback = function()
            table.insert(Util.activePlayer().powers, require('powers.asteroidcatcher'):new())
      end
      CardTemplate.play(self)
end

return card
