local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = {
      objectID = nil,
      title = "Test Card",
      text = "This is a debug card and you should not be reading this.",
      img = love.graphics.newImage("test_card.png"),

      x = 0,
      y = 0,
      targetX = 0,
      targetY = 0,
      speed = 800,
      scale = 1,
      targetScale = 1,
      rotation = 0,
      targetRotation = 0,
      w = 160, -- 210
      h = 200, -- 300
      color = { 1, 1, 1 },

      barterValue = 1,
      hidden = true,
      hideOnDestination = false,
      faceDown = false,
      dragging = false,
      highlight = false,
      highlightColour = { 96, 250, 45 },
      buyCost = 0,
      playCost = 0,
      playable = true,
      ethereal = false,
      power = false,
      isAsteroid = false,


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
            local i = #Game.players[Game.activePlayer].playedCards.cards
            self.targetY = UI.playedCards.y + 50 +
                ((math.modf((i * self.w) / love.graphics.getWidth())) * self.h)
            --     ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * card.h * card.scale)
            -- Reset to 0 X when row incremented
            self.targetX = UI.playedCards.x + (6 * i) + self.w * (i - 1) -
                ((math.modf((i * self.w) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / self.w) * self.w))
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
            o.objectID = #GameObjects + 1
            if self.title ~= "spacer" then
                  io.write("Created a new " .. self.title .. " card.\n")
            end
            table.insert(GameObjects, o.objectID, o)
            return o
      end,

      copy = function(self)
            local copy = {}
            setmetatable(copy, self)
            self.__index = self
            return self:new(self)
      end,

      draw = function(self)
            if self.hidden then
                  return
            end
            love.graphics.push()
            love.graphics.setColor(self.color)

            love.graphics.translate(self.x, self.y)
            love.graphics.rotate(self.rotation)
            love.graphics.scale(self.scale, self.scale)
            love.graphics.rectangle("fill", 0, 0, self.w, self.h)

            love.graphics.setColor(0, 0, 0)
            if self.buyCost > 0 then
                  love.graphics.print(self.buyCost, self.w * 0.9, 2)
            end
            love.graphics.printf(self.title, 0, 30, self.w, 'center')
            local t = self.text
            if self.playCost > 0 then
                  t = 'Discard ' .. self.playCost .. ' cards\n\n' .. self.text
            end
            love.graphics.printf(t, self.w * 0.1, self.h * 0.3, self.w * 0.8, 'center')
            if self.highlight then
                  love.graphics.setColor(self.highlightColour)
                  love.graphics.setLineWidth(5)
                  love.graphics.rectangle("line", 0, 0, self.w, self.h)
            end

            if self.ethereal then
                  love.graphics.printf("ETHEREAL", self.w * 0.1, self.h * 0.8, self.w * 0.8, 'center')
            end

            -- love.graphics.printf("targX: " .. self.targetX, self.w * 0.1, self.h * 0.8, self.w * 0.8,'center')
            love.graphics.printf("ID: " .. self.objectID, self.w * 0.1, self.h * 0.8, self.w * 0.8, 'center')
            if self.hidden then
                  love.graphics.printf("DEBUG HIDDEN", self.w * 0.1, self.h * 0.5, self.w * 0.8, 'center')
            end

            -- love.graphics.draw(self.img, self.x, self.y)
            love.graphics.pop()
      end,

      update = function(self, dt)
            if self.dragging then
                  self.targetX = self.x
                  self.targetY = self.y
            end
            -- Update position
            local dx = self.targetX - self.x
            local dy = self.targetY - self.y
            local distance = math.sqrt(dx ^ 2 + dy ^ 2)
            if distance > 10 then
                  local move_x = (dx / distance) * self.speed * dt
                  local move_y = (dy / distance) * self.speed * dt
                  self.x = self.x + move_x
                  self.y = self.y + move_y
            end
            if distance < 10 then
                  self.x = self.targetX
                  self.y = self.targetY
                  if self.hideOnDestination then
                        self.hidden = true
                  end
            end

            -- Update scale
            local ds = self.targetScale - self.scale
            if self.scale < self.targetScale then
                  self.scale = math.min(self.scale + ds, self.targetScale)
            elseif self.scale > self.targetScale then
                  self.scale = math.max(self.scale - ds, self.targetScale)
            end

            -- Update rotation
            local dr = self.targetRotation - self.rotation
            if self.rotation < self.targetRotation then
                  self.rotation = math.min(self.rotation + dr, self.targetRotation)
            elseif self.rotation > self.targetRotation then
                  self.rotation = math.max(self.rotation - dr, self.targetRotation)
            end
      end,

      destroy = function(self)
            -- Check hand, discard, deck and shop for the card and remove it if found
            local lists = {}

            for index, shop in ipairs(Shop) do
                  table.insert(lists, shop)
            end
            for index, player in ipairs(Game.players) do
                  table.insert(lists, player.hand)
                  table.insert(lists, player.discard)
                  table.insert(lists, player.deck)
            end

            for index, list in ipairs(lists) do
                  Util.removeFromList(list, self)
                  -- for index, card in ipairs(list) do
                  --       if card.objectID == self.objectID then
                  --             io.write("Found card " .. self.title .. " in list.\n")
                  --             -- card = nil
                  --       end
                  -- end
            end
            -- GameObjects[self.objectID] = nil
      end
}

return CardTemplate
