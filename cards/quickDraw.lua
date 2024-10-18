local CardTemplate = require('cards.template')

-- Card which discards 1 to draw 1
local quickDraw = CardTemplate:new()
quickDraw.title = "Quick Draw"
quickDraw.text = "Discard 1 card.\nDraw 1 card."
quickDraw.color = Util.colorConv({ 66, 135, 245 })
quickDraw.cost = 1
quickDraw.play = function(self)
      Game.discardCallback = function()
            Hand:drawCard(2)
      end
      CardTemplate.play(self)
end

return quickDraw
