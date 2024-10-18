local CardTemplate = require('cards.template')

local outpost = CardTemplate:new()

outpost.title = "Outpost"
outpost.text = "At the start of each turn add an ethereal asteroid to your hand."
outpost.color = Util.colorConv({ 200, 75, 210 })
outpost.buyCost = 1
outpost.playCost = 2
outpost.power = true
outpost.play = function(self)
      Game.discardCallback = function()
            table.insert(Util.activePlayer().powers, require('powers.outpost'))
      end
      CardTemplate.play(self)
end

return outpost
