local CardTemplate = require('cards.template')
local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local card = CardTemplate:new()

card.title = "Money Lender"
card.text = "Add 2 Buying Power.\nDestory all Asteroids used to play this."
card.color = Util.colorConv({ 200, 75, 210 })
card.buyCost = 2
card.playCost = 2
card.play = function(self)
      Game.discardCallback = function(cards)
            Util.activePlayer().buyingPower = Util.activePlayer().buyingPower + 2
            for key, v in pairs(cards) do
                  if v.isAsteroid then
                        io.write("Discarding a " .. v.title .. " card, removing.\n")
                        v:destroy()
                  end
            end
      end
      CardTemplate.play(self)
end

return card
