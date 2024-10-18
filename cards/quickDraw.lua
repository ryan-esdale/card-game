local CardTemplate = require('cards.template')

-- Card which discards 1 to draw 2
local quickDraw = CardTemplate:new()
quickDraw.title = "Quick Draw"
quickDraw.text = "Draw 2 card."
quickDraw.color = Util.colorConv({ 66, 135, 245 })
quickDraw.playCost = 1
quickDraw.play = function(self)
      Game.discardCallback = function()
            Game.players[Game.activePlayer].hand:drawCard(2)
      end
      CardTemplate.play(self)
end

return quickDraw
