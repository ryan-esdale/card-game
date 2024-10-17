local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = require('carddir/template')

local CARDS = {
      createCardFunc = function(template)
            return CardTemplate:new(template)
      end
}


-- require 'lib.require'
local d = love.filesystem.getDirectoryItems('carddir')
for index, v in ipairs(d) do
      local title = string.sub(v, 1, #v - 4)
      CARDS[title] = require('carddir.' .. title)
end

-- Dummy Test Card
local test_card = CardTemplate:new()
CARDS['testCard'] = test_card

-- Red card that makes blue card
-- Blue card that makes red card


local blueCard = CardTemplate:new()
local redCard = CardTemplate:new()
local greenCard = CardTemplate:new()

blueCard.title = "Blue Card"
blueCard.color = { 0, 0, 1 }
blueCard.play = function(self)
      table.insert(Hand.cards, redCard:new())
      table.insert(PlayedCards.cards, self)
end

redCard.title = "Red Card"
redCard.color = { 1, 0, 0 }
redCard.play = function(self)
      table.insert(Hand.cards, blueCard:new())
      table.insert(PlayedCards.cards, self)
end

CARDS['redCard'] = redCard
CARDS['blueCard'] = blueCard

-- Green that costs 2 and draws 4
greenCard.title = "Green Card"
greenCard.text = "Discard 2 cards \nDraw 4 cards."
greenCard.color = { 0, 1, 0 }
greenCard.cost = 2
greenCard.play = function(self)
      Game.discardCallback = function()
            Hand:drawCard(4)
      end

      CardTemplate.play(self)
end

CARDS['greenCard'] = greenCard


-- 0 Cost Card which adds 1 buying power
local copper = CardTemplate:new()
copper.title = "Copper"
copper.text = "Adds 1 buying power."
copper.color = { 255, 192, 0 }
copper.play = function(self)
      Game.buyingPower = Game.buyingPower + 1
      CardTemplate.play(self)
end
CARDS['copper'] = copper

-- Invisible spacer card
local spacer = CardTemplate:new()
spacer.title = "spacer"

CARDS['spacer'] = spacer


-- Card which discards 1 to draw 2
local quickDraw = CardTemplate:new()
quickDraw.title = "Quick Draw"
quickDraw.text = "Discard 1 card.\nDraw 1 card."
quickDraw.color = colorConv({ 66, 135, 245 })
quickDraw.cost = 1
quickDraw.play = function(self)
      Game.discardCallback = function()
            Hand:drawCard(2)
      end
      CardTemplate.play(self)
end
CARDS['quickDraw'] = quickDraw

-- Card which adds 1 buying Power when played
local discardMe = CardTemplate:new()
discardMe.title = "Discard Me"
discardMe.text = "UNPLAYABLE\nWhen discarded add 2 buying power."
discardMe.color = colorConv({ 199, 113, 113 })
discardMe.playable = false
discardMe.onDiscard = function(self)
      Game.buyingPower = Game.buyingPower + 2
end
CARDS['discardMe'] = discardMe

return CARDS
