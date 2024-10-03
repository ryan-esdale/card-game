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

      -- Game setup

      Game = {
            endTurn = function()
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
            addCard = function(self, card)
                  table.insert(self.cards, card)
                  io.write("Added a " .. card.text .. " card to hand.\n")
            end
      }

      Deck:addCard(Cards['blueCard']:new())
      Deck:addCard(Cards['blueCard']:new())
      Deck:addCard(Cards['blueCard']:new())
      Deck:addCard(Cards['greenCard']:new())
      Deck:addCard(Cards['greenCard']:new())

      -- Discard
      Discard = {
            cards = {}
      }


      Hand = {
            hasSpacer = false,
            spacerIndex = -1,
            cards = {},
            addCard = function(self, card)
                  table.insert(self.cards or {}, card)
                  io.write("Added a " .. card.text .. " card to hand.\n")
            end,
            drawCard = function(self, count)
                  for i = 1, count or 1, 1 do
                        if #Deck.cards < 1 then
                              table.move(Discard.cards, 1, #Discard.cards, 1, Deck.cards)
                              Discard.cards = {}
                        end
                        self.addCard(table.remove(Deck.cards))
                  end
            end,
            clear = function(self)
                  io.write("Clearing " .. #self.cards .. " from hand.\n")
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
                  io.write("Clearing " .. #self.cards .. ".\n")
                  for i = 1, #self.cards, 1 do
                        table.insert(Discard.cards, table.remove(self.cards))
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
            card.w = 213
            card.h = 300
            -- Increment Row when edge of screen reached
            card.y = 50 +
                ((math.modf((i * card.w) / love.graphics.getWidth())) * card.h)
            -- Reset to 0 X when row incremented
            card.x = card.w * (i - 1) -
                ((math.modf((i * card.w) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w) * card.w))
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


      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Played Cards: " .. #PlayedCards.cards, 100, 25)


      -- End turn button
      love.graphics.rectangle("fill", UI.endTurnButton.x, UI.endTurnButton.y, UI.endTurnButton.w, UI.endTurnButton.h)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print("END TURN", UI.endTurnButton.x + 5, UI.endTurnButton.y)


      -- love.graphics.print(Hand.spacerIndex)
end

function love.mousepressed(x, y, button, istouch)
      if button ~= 1 then
            return
      end
      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if x > Hand.cards[i].x and x <= Hand.cards[i].x + Hand.cards[i].w and y > Hand.cards[i].y and y <= Hand.cards[i].y + Hand.cards[i].h then
                  Hand.cards[i].dragging = true
                  cursorCard = Hand.cards[i]:new()
                  io.write("Picked up " .. cursorCard.text .. ".\n")
                  cursorCardID = i
                  table.remove(Hand.cards, i)
                  -- cursorCard.x = x - cursorCard.w
                  -- cursorCard.y = y - cursorCard.h
                  goto continue
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
                  cursorCard.text = indexToMove
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
