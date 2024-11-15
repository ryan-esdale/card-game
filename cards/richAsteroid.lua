local CardTemplate = require('cards.template')

local RichAsteroid = CardTemplate:new()
local asteroid = require('cards.asteroid')

RichAsteroid.title = "Rich Asteroid"
RichAsteroid.text = "Gain one buying power.\nWhen drawn, add an ethereal asteroid to your hand."
RichAsteroid.color = Util.colorConv({ 200, 75, 210 })
RichAsteroid.isAsteroid = true
RichAsteroid.play = function(self)
      Game.players[Game.activePlayer].buyingPower = Game.players[Game.activePlayer].buyingPower + 1
      CardTemplate.play(self)
end
RichAsteroid.onDraw = function(self)
      local a = asteroid:new()
      a.ethereal = true
      Game.players[Game.activePlayer].hand:addCard(a)
end

return RichAsteroid
