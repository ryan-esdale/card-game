local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)


function love.load()
      io.write("\n\n")
      -- Window layout setup
      love.window.setTitle("Test Window Title")
      love.window.setMode(2140, 1080)
      love.graphics.setBackgroundColor(0.2, 0.2, 0.2)


      -- Game setup

      GameObjects = {}

      -- Deck
      Deck = {

      }

      -- Card
      Cards = require('cards')

      Hand = {
            hasSpacer = false,
            spacerIndex = -1,
            cards = {},
            addCard = function(self, card)
                  table.insert(self.cards, card)
                  io.write("Added a " .. card.text .. " card to hand.\n")
            end
      }
      -- for i = 1, 5, 1 do
      --       local newCard = Card:new()
      --       newCard.color = { math.random(), math.random(), math.random() }
      --       Hand:addCard(newCard)
      -- end

      Hand:addCard(Cards['blueCard']:new())
      Hand:addCard(Cards['blueCard']:new())
      Hand:addCard(Cards['blueCard']:new())
      Hand:addCard(Cards['greenCard']:new())
      Hand:addCard(Cards['greenCard']:new())

      PlayedCards = {}
      table.insert(PlayedCards, Cards['greenCard']:new())

      cursorCard = nil
      cursorCardID = nil
end

function love.update(dt)

end

function love.draw()
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("fill", 0, love.graphics.getHeight() / 3 * 2, love.graphics.getWidth(),
            love.graphics.getHeight() / 3)

      -- love.graphics.setColor(1, 1, 1)
      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if Hand.cards[i].text == "spacer" then goto continue end
            if Hand.cards[i].dragging then
                  love.graphics.setColor(.5, .5, .5)
            else
                  love.graphics.setColor(Hand.cards[i].color)
                  Hand.cards[i].x = Hand.cards[i].w * (i - 1)
                  Hand.cards[i].y = love.graphics.getHeight() / 3 * 2
            end
            love.graphics.draw(Hand.cards[i].img, Hand.cards[i].x, Hand.cards[i].y)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(Hand.cards[i].text, Hand.cards[i].x, Hand.cards[i].y)
            ::continue::
      end

      if cursorCard then
            love.graphics.setColor(cursorCard.color)
            love.graphics.draw(cursorCard.img, cursorCard.x, cursorCard.y)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(cursorCard.text, cursorCard.x, cursorCard.y)
      end


      for i = 1, #PlayedCards, 1 do
            if not PlayedCards[i] then goto continue end
            local card = PlayedCards[i]
            love.graphics.setColor(card.color)
            card.w = 213
            card.h = 300
            card.x = card.w * (i - 1)
            card.y = 50
            love.graphics.draw(card.img, card.x, card.y)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(card.text, card.x, card.y)
            ::continue::
      end
      love.graphics.print("Played Cards: ", 100, 0)


      love.graphics.print(Hand.spacerIndex)
end

function love.mousepressed(x, y, button, istouch)
      if button ~= 1 then
            return
      end
      for i = 1, #Hand.cards, 1 do
            if i < 1 then return end
            if x > Hand.cards[i].x and x <= Hand.cards[i].x + Hand.cards[i].w and y > Hand.cards[i].y and y <= Hand.cards[i].y + Hand.cards[i].h then
                  Hand.cards[i].dragging = true
                  cursorCard = Hand.cards[i]:new()
                  io.write("Picked up " .. cursorCard.text .. ".\n")
                  cursorCardID = i
                  table.remove(Hand.cards, i)
                  -- cursorCard.x = x - cursorCard.w
                  -- cursorCard.y = y - cursorCard.h
                  return
            end
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
                  for i = #Hand.cards, 1, -1 do
                        if Hand.cards[i] and Hand.cards[i].text == "spacer" then
                              table.remove(Hand.cards, i)
                              -- Hand.hasSpacer = false
                              Hand.spacerIndex = -1
                        end
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
