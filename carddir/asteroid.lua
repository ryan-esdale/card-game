local CardTemplate = require('carddir.template')

local Asteroid = CardTemplate:new()

Asteroid.title = "Asteroid"
Asteroid.text = "Gain one buying power."
Asteroid.cost = 0
Asteroid.color = colorConv({ 180, 56, 194 })
Asteroid.play = function(self)
      Game.buyingPower = Game.buyingPower + 1
      CardTemplate.play(self)
end

return Asteroid
