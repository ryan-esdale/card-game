local CardTemplate = require('cards.template')

-- Card which adds 1 buying Power when played
local discardMe = CardTemplate:new()
discardMe.title = "Discard Me"
discardMe.text = "UNPLAYABLE\nWhen discarded add 2 buying power."
discardMe.color = Util.colorConv({ 199, 113, 113 })
discardMe.playable = false
discardMe.onDiscard = function(self)
      Game.buyingPower = Game.buyingPower + 2
end

return discardMe
