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

return CardTemplate
