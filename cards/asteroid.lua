local CardTemplate = require('cards.template')

local Asteroid = CardTemplate:new()

Asteroid.title = "Asteroid"
Asteroid.text = "Gain one buying power."
Asteroid.color = Util.colorConv({ 180, 56, 194 })
Asteroid.play = function(self)
      Game.players[Game.activePlayer].buyingPower = Game.players[Game.activePlayer].buyingPower + 1
      CardTemplate.play(self)
end

return Asteroid
