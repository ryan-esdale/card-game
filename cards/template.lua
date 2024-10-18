local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = {
      objectID = nil,
      title = "Test Card",
      text = "This is a debug card and you should not be reading this.",
      img = love.graphics.newImage("test_card.png"),

      x = 0,
      y = 0,
      scale = 0.6,
      w = 350 * 0.6,
      h = 500 * 0.6,
      color = { 1, 1, 1 },

      dragging = false,
      highlight = false,
      highlightColour = { 96, 250, 45 },
      buyCost = 0,
      playCost = 0,
      playable = true,
      ethereal = false,
      power = false,

      play = function(self)
            if self.playCost > 0 then
                  Game.discardCount = self.playCost
                  Game.cursorMode = CursorMode.discard
                  for key, value in pairs(Game.players[Game.activePlayer].hand.cards) do
                        value.highlight = true
                        value.highlightColour = UI.colours.AVAILABLE
                  end
            end
            table.insert(Game.players[Game.activePlayer].playedCards.cards, self)
      end,

      onDiscard = function(self)
            if self.ethereal then
                  self = {}
            end
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
            if self.buyCost > 0 then
                  love.graphics.print(self.buyCost, self.x + self.w * 0.9, self.y + 2)
            end
            love.graphics.printf(self.title, self.x, self.y + 30, self.w, 'center')
            love.graphics.printf(self.text, self.x + self.w * 0.1, self.y + self.h * 0.3, self.w * 0.8, 'center')
            if self.highlight then
                  love.graphics.setColor(self.highlightColour)
                  love.graphics.setLineWidth(5)
                  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
            end

            if self.ethereal then
                  love.graphics.printf("ETHEREAL", self.x + self.w * 0.1, self.y + self.h * 0.8, self.w * 0.8, 'center')
            end
      end
}

return CardTemplate
