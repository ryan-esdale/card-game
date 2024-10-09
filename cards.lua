local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = {
      objectID = nil,
      title = "Test Card",
      text = "This is a debug card and you should not be reading this.",
      img = love.graphics.newImage("test_card.png"),
      dragging = false,
      x = 0,
      y = 0,
      scale = 0.6,
      w = 350 * 0.6,
      h = 500 * 0.6,
      highlight = false,
      highlightColour = { 96, 250, 45 },
      cost = 0,
      color = { 1, 1, 1 },
      playable = true,

      play = function(self)
            if self.cost > 0 then
                  Game.discardCount = self.cost
                  Game.cursorMode = CursorMode.discard
                  for key, value in pairs(Hand.cards) do
                        value.highlight = true
                        value.highlightColour = UI.colours.AVAILABLE
                  end
            end
            table.insert(PlayedCards.cards, self)
      end,

      onDiscard = function(self)
      end,

      onDraw = function(self)
      end,

      new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            if self.title ~= "spacer" then
                  io.write("Created a new " .. self.title .. " card.\n")
            end
            return o
      end,

      copy = function(self)
            local copy = {}
            setmetatable(copy, self)
            self.__index = self
            return self:new(self)
      end,

      draw = function(self)
            love.graphics.setColor(self.color)
            -- love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale)
            love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(self.cost, self.x + self.w * 0.9, self.y + 2)
            love.graphics.printf(self.title, self.x, self.y + 30, self.w, 'center')
            love.graphics.printf(self.text, self.x + self.w * 0.1, self.y + self.h * 0.3, self.w * 0.8, 'center')
            if self.highlight then
                  love.graphics.setColor(self.highlightColour)
                  love.graphics.setLineWidth(5)
                  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            end
      end
}


local CARDS = {
      createCardFunc = function(template)
            return CardTemplate:new(template)
      end
}

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
quickDraw.color = { 66, 135, 245 }
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
discardMe.color = { 99, 13, 13 }
discardMe.playable = false
discardMe.onDiscard = function(self)
      Game.buyingPower = Game.buyingPower + 2
end
CARDS['discardMe'] = discardMe

return CARDS
