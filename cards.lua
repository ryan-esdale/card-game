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
      color = { 1, 1, 1 },
      play = function(self)
            -- local newCard = CardTemplate:new()
            -- newCard.color = { math.random(), math.random(), math.random() }
            -- table.insert(Hand.cards, newCard)
            table.insert(PlayedCards, self)
      end,
      new = function(self, o)
            o = o or {}
            setmetatable(o, self)
            self.__index = self
            io.write("Created a new " .. self.text .. " card.\n")
            return o
      end,
      copy = function(self)
            local copy = {}
            setmetatable(copy, self)
            self.__index = self
            return self:new(self)
      end
}


local CARDS = {
}

-- Dummy Test Card
local test_card = CardTemplate:new()
table.insert(CARDS, test_card)

-- Red card that makes blue card
-- Blue card that makes red card
-- Green that makes itself

local blueCard = CardTemplate:new()
local redCard = CardTemplate:new()
local greenCard = CardTemplate:new()

blueCard.text = "Blue Card"
blueCard.color = { 0, 0, 1 }
blueCard.play = function(self)
      table.insert(Hand.cards, redCard:new())
      table.insert(PlayedCards, self)
end

redCard.text = "Red Card"
redCard.color = { 1, 0, 0 }
redCard.play = function(self)
      table.insert(Hand.cards, blueCard:new())
      table.insert(PlayedCards, self)
end

greenCard.text = "Green Card"
greenCard.color = { 0, 1, 0 }
greenCard.play = function(self)
      table.insert(Hand.cards, greenCard:new())
      table.insert(PlayedCards, self)
end

CARDS['redCard'] = redCard
CARDS['blueCard'] = blueCard
CARDS['greenCard'] = greenCard


-- Invisible spacer card
local spacer = CardTemplate:new()
spacer.text = "spacer"

CARDS['spacer'] = spacer

return CARDS
