local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)


function love.load()
      io.write("\n\n")
      -- Window layout setup
      love.window.setTitle("Test Window Title")
      love.window.setMode(2140, 1080)
      love.graphics.setBackgroundColor(0.2, 0.2, 0.2)


      -- UI Setup

      UI = {
            playArea = {
                  x = 100,
                  y = 100,
                  color = { 0.75, 0.75, 0.75 }
            },
            hand = {
                  x = 0,
                  y = love.graphics.getHeight() / 3 * 2,
                  color = { 0.6, 0.6, 0.6 }
            },
            endTurnButton = {
                  w = 100,
                  h = 50,
                  x = love.graphics.getWidth() - 100,
                  y = love.graphics.getHeight() / 2 - 25,
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
            end
      }
      GameObjects = {}

      -- Card
      Cards = require('cards')

      -- Deck
      Deck = {
            cards = {},
            addCard = function(self, card, count)
                  for i = 1, count or 1, 1 do
                        local tempCard = Cards[card]:new()
                        table.insert(self.cards, tempCard)
                        io.write("Added a " .. tempCard.text .. " card to hand.\n")
                  end
            end
      }


      Deck:addCard('greenCard', 3)
      Deck:addCard('copper', 7)

      -- Discard
      Discard = {
            cards = {}
      }


      Hand = {
            hasSpacer = false,
            spacerIndex = -1,
            cards = {},
            addCard = function(self, card)
                  table.insert(self.cards, card)
                  io.write("Added a " .. card.text .. " card to hand.\n")
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
                  end
            end,
            discard = function(self, index)
                  if not self.cards[index] then
                        return
                  end
                  local cardToDiscard = self.cards[index]
                  io.write("Discarding " .. cardToDiscard.text .. " card.\n")
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
                        card.scale = 1
                        table.insert(Discard.cards or {}, card)
                  end
                  io.write("Cleared Played Cards.\n")
            end
      }

      cursorCard = nil
      cursorCardID = nil
end

function love.update(dt)

end

function love.draw()
      -- Played Cards
      for i = 1, #PlayedCards.cards, 1 do
            if not PlayedCards.cards[i] then goto continue end
            local card = PlayedCards.cards[i]
            card.scale = 0.6
            -- Increment Row when edge of screen reached
            card.y = 50 +
                ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * card.h * card.scale)
            -- Reset to 0 X when row incremented
            card.x = card.w * card.scale * (i - 1) -
                ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w * card.scale) * card.w * card.scale))
            card.text = tostring(card.scale)
            card:draw()
            ::continue::
      end

      -- Hand and cards in Hand
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("fill", 0, love.graphics.getHeight() / 3 * 2, love.graphics.getWidth(),
            love.graphics.getHeight() / 3)

      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if Hand.cards[i].text == "spacer" then goto continue end
            Hand.cards[i].x = Hand.cards[i].w * (i - 1)
            Hand.cards[i].y = love.graphics.getHeight() / 3 * 2
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
            if x > Hand.cards[i].x and x <= Hand.cards[i].x + Hand.cards[i].w and y > Hand.cards[i].y and y <= Hand.cards[i].y + Hand.cards[i].h then
                  local selectedCard = Hand.cards[i]
                  if Game.cursorMode == CursorMode.none then
                        -- Hand.cards[i].dragging = true
                        cursorCard = selectedCard:new()
                        io.write("Picked up " .. cursorCard.text .. ".\n")
                        cursorCardID = i
                        table.remove(Hand.cards, i)
                        -- cursorCard.x = x - cursorCard.w
                        -- cursorCard.y = y - cursorCard.h
                        goto continue
                  elseif Game.cursorMode == CursorMode.discard then
                        io.write("Discarding " .. selectedCard.text .. ".\n")
                        Hand:discard(i)
                        Game.discardCount = Game.discardCount - 1
                        if Game.discardCount <= 0 then
                              Game.discardCallback()
                              Game.cursorMode = CursorMode.none
                        end
                  end
            end
            ::continue::
      end
      if x > UI.endTurnButton.x and x <= (UI.endTurnButton.x + UI.endTurnButton.w) and y > UI.endTurnButton.y and y <= (UI.endTurnButton.y + UI.endTurnButton.h) then
            Game.endTurn()
      end
end

function love.mousereleased(x, y, button, istouch)
      -- Iterate backwards so removing doesn't skip items
      if cursorCard then
            if (cursorCard.y + cursorCard.h / 2) < love.graphics.getHeight() / 3 * 2 then
                  cursorCard:play()
            else
                  cursorCard.dragging = false
                  local indexToMove = math.modf(x / cursorCard.w) + 1 -- Add one becuase lua arrays are 1-indexed
                  if indexToMove > #Hand.cards + 1 then indexToMove = #Hand.cards + 1 end
                  table.insert(Hand.cards, indexToMove, cursorCard:new())
                  io.write("Dropped " .. cursorCard.text .. ".\n")
            end
            for i = #Hand.cards, 1, -1 do
                  if Hand.cards[i] and Hand.cards[i].text == "spacer" then
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
                  cursorCard.text = indexToMove

                  if indexToMove then
                        if Hand.spacerIndex ~= indexToMove then
                              Hand.spacerIndex = indexToMove
                              for i = #Hand.cards, 1, -1 do
                                    if not Hand.cards[i] then
                                          goto continue
                                    end
                                    if Hand.cards[i].text == "spacer" then
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
                        if Hand.cards[i].text == "spacer" then
                              table.remove(Hand.cards, i)
                        end
                        ::continue::
                  end
                  Hand.spacerIndex = -1
            end
      end
end

function love.keypressed(key)
      if key == 'q' then
            love.event.quit()
      end
end
