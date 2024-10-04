local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = {
      objectID = nil,
      text = "Test Card",
      img = love.graphics.newImage("test_card.png"),
      dragging = false,
      x = 0,
      y = 0,
      w = 355, --has 5px buffer
      h = 500,
      scale = 1,
      cost = 0,
      color = { 1, 1, 1 },
      play = function(self)
            if self.cost > 0 then
                  Game.discardCount = self.cost
                  Game.cursorMode = CursorMode.discard
            end
            table.insert(PlayedCards.cards, self)
      end,
      new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            if self.text ~= "spacer" then
                  io.write("Created a new " .. self.text .. " card.\n")
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
            love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(self.text, self.x, self.y)
      end
}


local CARDS = {
      createCardFunc = function(template)
            return CardTemplate:new(template)
      end
}

-- Dummy Test Card
local test_card = CardTemplate:new()
CARDS['testCards'] = test_card

-- Red card that makes blue card
-- Blue card that makes red card
-- Green that does nothing

local blueCard = CardTemplate:new()
local redCard = CardTemplate:new()
local greenCard = CardTemplate:new()

blueCard.text = "Blue Card"
blueCard.color = { 0, 0, 1 }
blueCard.play = function(self)
      table.insert(Hand.cards, redCard:new())
      table.insert(PlayedCards.cards, self)
end

redCard.text = "Red Card"
redCard.color = { 1, 0, 0 }
redCard.play = function(self)
      table.insert(Hand.cards, blueCard:new())
      table.insert(PlayedCards.cards, self)
end

greenCard.text = "Green Card"
greenCard.color = { 0, 1, 0 }
greenCard.cost = 2
greenCard.play = function(self)
      Game.discardCallback = function()
            Hand:drawCard(4)
      end

      CardTemplate.play(self)
end

CARDS['redCard'] = redCard
CARDS['blueCard'] = blueCard
CARDS['greenCard'] = greenCard


-- 0 Cost Card which adds 1 buying power
local copper = CardTemplate:new()
copper.text = "Copper"
copper.color = { 255, 192, 0 }
copper.play = function(self)
      Game.buyingPower = Game.buyingPower + 1
      CardTemplate.play(self)
end
CARDS['copper'] = copper

-- Invisible spacer card
local spacer = CardTemplate:new()
spacer.text = "spacer"

CARDS['spacer'] = spacer

return CARDS
