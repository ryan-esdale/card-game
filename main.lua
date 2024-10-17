local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)


function checkMouseOver(x, y, object)
      if object.x and object.y and object.w and object.h then
            if x > object.x and x <= object.x + object.w and y > object.y and y <= object.y + object.h then
                  return true
            end
      end
      return false
end

function colorConv(tuple)
      if #tuple ~= 3 then
            return { 0, 0, 0 }
      end
      return { tuple[1] / 255, tuple[2] / 255, tuple[3] / 255 }
end

function love.load()
      io.write("\n\n")

      -- Window layout setup
      love.window.setTitle("Test Window Title")
      love.window.setMode(2500, 1200)
      love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

      -- UI Setup

      UI = {
            shop = {
                  x = 50,
                  y = 50,
            },
            playArea = {
                  x = 100,
                  y = 100,
                  color = { 0.75, 0.75, 0.75 }
            },
            playedCards = {
                  x = 0,
                  y = 400
            },
            hand = {
                  x = 0,
                  y = love.graphics.getHeight() / 3 * 2,
                  w = love.graphics.getWidth() - 700,
                  h = love.graphics.getHeight() / 3,
                  color = { 0.6, 0.6, 0.6 }
            },
            endTurnButton = {
                  w = 100,
                  h = 50,
                  x = love.graphics.getWidth() - 100,
                  y = love.graphics.getHeight() / 2 - 25,
            },
            colours = {
                  HIGHLIGHT = { 235, 235, 235 },
                  SELECTED = { 96, 250, 45 },
                  AVAILABLE = { 255, 217, 0 }
            }
      }


      -- Cursor Modes
      CursorMode = {
            none = "NONE",
            dragging = "DRAGGING",
            discard = "DISCARD"
      }

      -- Game setup

      Game = {
            cursorMode = CursorMode.none,
            discardCount = 0,
            discardCallback = function()
            end,
            turnCount = 1,
            buyingPower = 0,
            endTurn = function()
                  Game.buyingPower = 0
                  Hand:clear()
                  PlayedCards:clear()
                  Hand:drawCard(5)
                  Game.turnCount = Game.turnCount + 1
            end
      }
      GameObjects = {}

      -- Card
      Cards = require('cards')

      -- Deck
      Deck = {
            graphic = Cards['testCard']:new(),
            cards = {},
            addCard = function(self, card, count)
                  for i = 1, count or 1, 1 do
                        local tempCard = Cards[card]:new()
                        table.insert(self.cards, tempCard)
                        io.write("Added a " .. tempCard.title .. " card to deck.\n")
                  end
            end
      }
      Deck.graphic.color = { 1, 1, 1 }
      Deck.graphic.x = UI.hand.x + UI.hand.w + 50
      Deck.graphic.y = UI.hand.y + 5
      Deck.graphic.title = 'Deck'


      Deck:addCard('asteroid', 8)
      Deck:addCard('discardMe')
      Deck:addCard('quickDraw')

      -- Discard
      Discard = {
            graphic = Cards['testCard']:new(),
            cards = {}
      }
      Discard.graphic.color = { 1, 1, 1 }
      Discard.graphic.x = UI.hand.x + UI.hand.w + Discard.graphic.w + 100
      Discard.graphic.y = UI.hand.y + 5
      Discard.graphic.title = 'Discard'


      Hand = {
            hasSpacer = false,
            spacerIndex = -1,
            cards = {},
            addCard = function(self, card)
                  table.insert(self.cards, card)
                  io.write("Added a " .. card.title .. " card to hand.\n")
            end,
            drawCard = function(self, count)
                  io.write("Drawing " .. count .. " cards.\n")
                  for i = 1, count or 1, 1 do
                        if #Deck.cards < 1 then
                              io.write("Not enough cards in deck, forcing reshuffle.\n")
                              table.move(Discard.cards, 1, #Discard.cards, 1, Deck.cards)
                              Discard.cards = {}
                              if #Deck.cards == 0 then
                                    return
                              end
                        end
                        self:addCard(table.remove(Deck.cards))
                        self.cards[#self.cards]:onDraw()
                  end
            end,
            discard = function(self, index)
                  if not self.cards[index] then
                        return
                  end
                  local cardToDiscard = self.cards[index]
                  io.write("Discarding " .. cardToDiscard.title .. " card.\n")
                  cardToDiscard:onDiscard()
                  table.insert(Discard.cards, table.remove(self.cards, index))
            end,

            clear = function(self)
                  io.write("Clearing " .. #self.cards .. " cards from hand.\n")
                  for i = 1, #self.cards, 1 do
                        table.insert(Discard.cards, table.remove(self.cards))
                  end
                  io.write("Cleared cards from hand.\n")
            end

      }
      for i = 1, 5, 1 do
            Hand:addCard(table.remove(Deck.cards))
      end

      PlayedCards = {
            cards = {},
            clear = function(self)
                  io.write("Clearing " .. #self.cards .. " played cards.\n")
                  for i = 1, #self.cards, 1 do
                        local card = table.remove(self.cards)
                        card.scale = Cards['testCard'].scale
                        table.insert(Discard.cards or {}, card)
                  end
                  io.write("Cleared Played Cards.\n")
            end
      }

      Shop = {
            {}
      }
      for i = 1, 10, 1 do
            local tempCard = Cards['greenCard']:new()
            table.insert(Shop[1], tempCard)
            io.write("Added a " .. tempCard.title .. " card to Shop.\n")
      end

      cursorCard = nil
      cursorCardID = nil
end

function love.update(dt)

end

function love.draw()
      --Shop
      for i = 1, #Shop, 1 do
            if #Shop[i] > 0 then
                  Shop[i][1].x = UI.shop.x + (i - 1) * Shop[i][1].w
                  Shop[i][1].y = UI.shop.y
                  Shop[i][1]:draw()
                  love.graphics.setColor(1, 1, 1)
                  love.graphics.printf(#Shop[i] .. "Remaining", Shop[i][1].x, Shop[i][1].y + Shop[i][1].h + 10,
                        Shop[i][1].w, 'center')
            end
      end

      -- Deck
      Deck.graphic.text = #Deck.cards .. " Card(s)"
      Deck.graphic:draw()

      -- Discard
      Discard.graphic.text = #Discard.cards .. " Card(s)"
      Discard.graphic:draw()

      -- Played Cards
      for i, card in ipairs(PlayedCards.cards) do
            -- if not PlayedCards.cards[i] then goto continue end
            -- card.scale = 0.6
            -- Increment Row when edge of screen reached
            card.y = UI.playedCards.y + 50 +
                ((math.modf((i * card.w) / love.graphics.getWidth())) * card.h)
            --     ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * card.h * card.scale)
            -- Reset to 0 X when row incremented
            card.x = UI.playedCards.x + (6 * i) + card.w * (i - 1) -
                ((math.modf((i * card.w) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w) * card.w))
            -- card.x = (6 * i) + card.w * card.scale * (i - 1) - ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w * card.scale) * card.w * card.scale))
            card:draw()
            -- ::continue::
      end

      -- Hand and cards in Hand
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("fill", UI.hand.x, UI.hand.y, UI.hand.w, UI.hand.h)

      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if Hand.cards[i].title == "spacer" then goto continue end
            Hand.cards[i].x = UI.hand.x + Hand.cards[i].w * (i - 1) + (8 * i)
            Hand.cards[i].y = UI.hand.y + 5
            Hand.cards[i]:draw()
            ::continue::
      end

      -- Cursor Card
      if cursorCard then
            cursorCard:draw()
      end

      -- Turn stats
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Buying Power: " .. Game.buyingPower, 0, 25)

      -- Discard indicator
      if Game.cursorMode == CursorMode.discard then
            love.graphics.print("Choose " .. Game.discardCount .. " more card(s) to discard.", 100, 200, 0, 10, 10)
      end

      -- End turn button
      love.graphics.rectangle("fill", UI.endTurnButton.x, UI.endTurnButton.y, UI.endTurnButton.w, UI.endTurnButton.h)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print("END TURN", UI.endTurnButton.x + 5, UI.endTurnButton.y)


      -- Debug stuff
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Cards in hand: " ..
            #Hand.cards ..
            ", Cards in Play: " ..
            #PlayedCards.cards .. ", Cards in Deck: " .. #Deck.cards .. ", Cards in Discard: " .. #Discard.cards)
end

function love.mousepressed(x, y, button, istouch)
      if button ~= 1 then
            return
      end
      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if checkMouseOver(x, y, Hand.cards[i]) then
                  local selectedCard = Hand.cards[i]
                  if Game.cursorMode == CursorMode.none then
                        -- Hand.cards[i].dragging = true
                        cursorCard = selectedCard:new()
                        cursorCard.highlight = false
                        io.write("Picked up " .. cursorCard.title .. ".\n")
                        cursorCardID = i
                        table.remove(Hand.cards, i)
                        -- cursorCard.x = x - cursorCard.w
                        -- cursorCard.y = y - cursorCard.h
                        goto continue
                  elseif Game.cursorMode == CursorMode.discard then
                        io.write("Discarding " .. selectedCard.title .. ".\n")
                        Hand:discard(i)
                        Game.discardCount = Game.discardCount - 1
                        if Game.discardCount <= 0 then
                              Game.discardCallback()
                              Game.cursorMode = CursorMode.none
                              for index, value in ipairs(Hand.cards) do
                                    value.highlight = false
                                    value.highlightColour = UI.colours.HIGHLIGHT
                              end
                        end
                  end
            end
            ::continue::
      end
      for i = 1, #Shop, 1 do
            if #Shop[i] > 0 and checkMouseOver(x, y, Shop[i][1]) then
                  if Game.buyingPower >= Shop[i][1].cost then
                        Game.buyingPower = Game.buyingPower - Shop[i][1].cost
                        table.insert(Discard.cards, table.remove(Shop[i]))
                  end
            end
      end
      if checkMouseOver(x, y, UI.endTurnButton) then
            Game.endTurn()
      end
end

function love.mousereleased(x, y, button, istouch)
      -- Iterate backwards so removing doesn't skip items
      if cursorCard then
            if (cursorCard.y + cursorCard.h / 2) < love.graphics.getHeight() / 3 * 2 and cursorCard.playable then
                  cursorCard:play()
            else
                  cursorCard.dragging = false
                  local indexToMove = math.modf(x / cursorCard.w) + 1 -- Add one becuase lua arrays are 1-indexed
                  if indexToMove > #Hand.cards + 1 then indexToMove = #Hand.cards + 1 end
                  table.insert(Hand.cards, indexToMove, cursorCard:new())
                  io.write("Dropped " .. cursorCard.title .. ".\n")
            end
            for i = #Hand.cards, 1, -1 do
                  if Hand.cards[i] and Hand.cards[i].title == "spacer" then
                        table.remove(Hand.cards, i)
                        -- Hand.hasSpacer = false
                        Hand.spacerIndex = -1
                  end
            end
      end
      cursorCard = nil
      cursorCardID = nil
end

function love.mousemoved(x, y, dx, dy)
      if cursorCard then
            cursorCard.x = cursorCard.x + dx
            cursorCard.y = cursorCard.y + dy

            if cursorCard.y + cursorCard.h > love.graphics.getHeight() / 3 * 2 then
                  local indexToMove = math.modf(x / cursorCard.w) + 1 -- Add one becuase lua arrays are 1-indexed
                  if indexToMove > #Hand.cards + 1 then indexToMove = #Hand.cards + 1 end

                  if indexToMove then
                        if Hand.spacerIndex ~= indexToMove then
                              Hand.spacerIndex = indexToMove
                              for i = #Hand.cards, 1, -1 do
                                    if not Hand.cards[i] then
                                          goto continue
                                    end
                                    if Hand.cards[i].title == "spacer" then
                                          table.remove(Hand.cards, i)
                                    end
                                    ::continue::
                              end
                              table.insert(Hand.cards, indexToMove, Cards['spacer']:new())
                        end
                        -- if not Hand.hasSpacer then
                        --       Hand.hasSpacer = true
                        -- end
                  end
            else
                  for i = #Hand.cards, 1, -1 do
                        if not Hand.cards[i] then
                              goto continue
                        end
                        if Hand.cards[i].title == "spacer" then
                              table.remove(Hand.cards, i)
                        end
                        ::continue::
                  end
                  Hand.spacerIndex = -1
            end
      else
            if Game.cursorMode == CursorMode.none then
                  for index, value in ipairs(Hand.cards) do
                        if checkMouseOver(x, y, value) then
                              value.highlight = true
                              value.highlightColour = UI.colours.SELECTED
                        else
                              value.highlight = false
                        end
                  end
            end
      end
end

function love.keypressed(key)
      if key == 'q' then
            love.event.quit()
      end
end
