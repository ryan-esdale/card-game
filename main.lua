local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

Util = require('lib.util')
Player = require('player')
GameObjects = {}

function love.load()
      io.write("\n\n")

      -- Window layout setup
      love.window.setTitle("Test Window Title")
      love.window.setMode(1500, 900)
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
                  w = love.graphics.getWidth() - 500,
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
            discard = "DISCARD",
            clickInteraction = "CLICKING"
      }

      -- Card
      Cards = require('loadCards')

      -- Game setup
      Game = {
            maxPlayers = 1,
            players = {},
            activePlayer = 1,
            cursorMode = CursorMode.none,
            discardCount = 0,
            discardingList = {},
            discardCallback = function()
            end,
            clickInteractionTargets = {},
            clickInteractionCallback = function(obj)
            end,
            turnCount = 1,
            pointsPool = 15,
            gameOver = false,
            endTurn = function()
                  if Game.pointsPool <= 0 then
                        Game.gameOver = true
                        return
                  end
                  local p = Game.players[Game.activePlayer]
                  p.buyingPower = 0
                  p.hand:clear()
                  p.playedCards:clear()
                  p.hand:drawCard(5)
                  -- We do a little TODO hack for local multiplayer
                  for index, card in ipairs(p.hand.cards) do
                        card.hidden = true
                  end
                  Game.turnCount = Game.turnCount + 1
                  Game.activePlayer = Game.activePlayer + 1
                  if Game.activePlayer > Game.maxPlayers then
                        Game.activePlayer = 1
                  end
                  -- We do a little TODO hack for local multiplayer
                  for index, card in ipairs(Util.activePlayer().hand.cards) do
                        card.hidden = false
                  end
                  if Util.activePlayer().powers then
                        for key, value in pairs(Util.activePlayer().powers) do
                              if value.type == 'turnStart' then
                                    value.effect()
                              end
                        end
                  end
            end
      }
      for i = 1, Game.maxPlayers, 1 do
            -- Deck
            local p = Player:new(i)
            Game.players[i] = p


            p.deck = {
                  graphic = Cards['testCard']:new(),
                  cards = {},
                  addCard = function(self, card, count)
                        for i = 1, count or 1, 1 do
                              local tempCard = Cards[card]:new()
                              tempCard.targetX = p.deck.graphic.x
                              tempCard.targetY = p.deck.graphic.y
                              table.insert(self.cards, tempCard)
                              io.write("Added a " .. tempCard.title .. " card to deck.\n")
                        end
                  end,
                  new = function(self)
                        local o = {}
                        setmetatable(o, self)
                        self.__index = self
                        return o
                  end,
            }

            -- setmetatable(p.deck.cards, { __mode = 'v' })
            p.deck:addCard('asteroid', 7)
            p.deck:addCard('discardMe')
            p.deck:addCard('quickDraw')
            p.deck:addCard('richAsteroid')
            p.deck:addCard('wreckageRecovery')
            Util.shuffle(p.deck.cards)
            p.deck.graphic.color = { 1, 1, 1 }
            p.deck.graphic.hidden = false
            p.deck.graphic.x = UI.hand.x + UI.hand.w + 50
            p.deck.graphic.y = UI.hand.y + 5
            p.deck.graphic.targetX = p.deck.graphic.x
            p.deck.graphic.targetY = p.deck.graphic.y

            p.deck.graphic.y = UI.hand.y + 5
            p.deck.graphic.title = 'Deck'

            p.discard = {
                  graphic = Cards['testCard']:new(),
                  cards = {}
            }

            -- setmetatable(p.discard.cards, { __mode = 'v' })
            -- Discard
            p.discard.graphic.color = { 1, 1, 1 }
            p.discard.graphic.hidden = false
            p.discard.graphic.x = UI.hand.x + UI.hand.w + p.discard.graphic.w + 100
            p.discard.graphic.y = UI.hand.y + 5
            p.discard.graphic.targetX = p.discard.graphic.x
            p.discard.graphic.targetY = p.discard.graphic.y
            p.discard.graphic.title = 'Discard'

            p.hand = {
                  hasSpacer = false,
                  spacerIndex = -1,
                  cards = {},
                  addCard = function(self, card)
                        card.targetX = UI.hand.x + #self.cards * card.w
                        card.targetY = UI.hand.y + 3
                        card.hideOnDestination = false
                        if p.playerID == Util.activePlayer().playerID then
                              card.hidden = false
                        end
                        table.insert(self.cards, card)
                        io.write("Added a " .. card.title .. " card to hand.\n")
                  end,
                  drawCard = function(self, count)
                        io.write("Drawing " .. count .. " cards.\n")
                        for i = 1, count or 1, 1 do
                              if #p.deck.cards < 1 then
                                    io.write("Not enough cards in deck, forcing reshuffle.\n")
                                    table.move(p.discard.cards, 1, #p.discard.cards, 1,
                                          p.deck.cards)
                                    p.discard.cards = {}
                                    Util.shuffle(p.deck.cards)
                                    if #p.deck.cards == 0 then
                                          return
                                    end
                              end
                              self:addCard(table.remove(p.deck.cards))
                              self.cards[#self.cards]:onDraw()
                        end
                  end,
                  discard = function(self, index)
                        if not self.cards[index] then
                              return
                        end
                        local cardToDiscard = table.remove(self.cards, index)

                        io.write("Discarding " .. cardToDiscard.title .. " card.\n")
                        cardToDiscard:onDiscard()
                        cardToDiscard.hideOnDestination = true
                        cardToDiscard.targetX = p.discard.graphic.x
                        cardToDiscard.targetY = p.discard.graphic.y
                        if not cardToDiscard.ethereal then
                              table.insert(p.discard.cards, cardToDiscard)
                        else
                              cardToDiscard:destroy()
                        end
                  end,

                  clear = function(self)
                        io.write("Clearing " .. #self.cards .. " cards from hand.\n")
                        for i = 1, #self.cards, 1 do
                              local c = table.remove(self.cards)
                              if c then
                                    if not c.ethereal then
                                          c.hideOnDestination = true
                                          c.targetX = p.discard.graphic.x
                                          c.targetY = p.discard.graphic.y
                                          table.insert(p.discard.cards, c)
                                    else
                                          c:destroy()
                                    end
                              end
                        end
                        io.write("Cleared cards from hand.\n")
                  end

            }
            -- setmetatable(p.hand.cards, { __mode = 'v' })
            for i = 1, 5, 1 do
                  p.hand:addCard(table.remove(p.deck.cards))
            end

            p.playedCards = {
                  cards = {},
                  clear = function(self)
                        io.write("Clearing " .. #self.cards .. " played cards.\n")
                        for i = 1, #self.cards, 1 do
                              local card = table.remove(self.cards)
                              card.scale = Cards['testCard'].scale
                              card.hideOnDestination = true
                              card.targetX = p.discard.graphic.x
                              card.targetY = p.discard.graphic.y
                              if not card.ethereal and not card.power then
                                    table.insert(p.discard.cards, card)
                              else
                                    card:destroy()
                              end
                        end
                        io.write("Cleared Played Cards.\n")
                  end
            }
      end



      Shop = {
            {},
            {},
            {},
            {}
      }
      for i = 1, 10, 1 do
            local tempCard = Cards['fastLooting']:new()
            table.insert(Shop[1], tempCard)
            io.write("Added a " .. tempCard.title .. " card to Shop.\n")
      end

      for i = 1, 10, 1 do
            local tempCard = Cards['outpost']:new()
            table.insert(Shop[2], tempCard)
            io.write("Added a " .. tempCard.title .. " card to Shop.\n")
      end

      for i = 1, 10, 1 do
            local tempCard = Cards['asteroidGenerator']:new()
            table.insert(Shop[3], tempCard)
            io.write("Added a " .. tempCard.title .. " card to Shop.\n")
      end

      for i = 1, 10, 1 do
            local tempCard = Cards['moneyLender']:new()
            table.insert(Shop[4], tempCard)
            io.write("Added a " .. tempCard.title .. " card to Shop.\n")
      end

      for i = 1, #Shop, 1 do
            if #Shop[i] > 0 then
                  for j = 1, #Shop[i], 1 do
                        Shop[i][j].targetX = UI.shop.x + (i - 1) * Shop[i][j].w + i * 10
                        Shop[i][j].targetY = UI.shop.y
                        Shop[i][j].hidden = false
                  end
            end
      end

      cursorCard = nil
      cursorCardID = nil
end

function love.update(dt)
      for index, obj in ipairs(GameObjects) do
            obj:update(dt)
      end
end

function love.draw()
      if Game.gameOver then
            love.graphics.print("Game Over", 200, 200)
            love.graphics.print("Final Scores:", 200, 250)
            local y = 300
            for index, value in ipairs(Game.players) do
                  love.graphics.print("Player " .. index .. ": " .. Game.players[index].points, 200, y)
                  y = y + 50
            end
            return
      end

      --Shop
      for i = 1, #Shop, 1 do
            if #Shop[i] > 0 then
                  love.graphics.setColor(1, 1, 1)
                  love.graphics.printf(#Shop[i] .. " Remaining", Shop[i][#Shop].x,
                        Shop[i][#Shop].y + Shop[i][#Shop].h + 10,
                        Shop[i][#Shop].w, 'center')
            end
      end

      -- Deck
      Game.players[Game.activePlayer]
      .deck.graphic.text = #Game.players[Game.activePlayer].deck.cards .. " Card(s)"

      -- Discard
      Game.players[Game.activePlayer]
      .discard.graphic.text = #Game.players[Game.activePlayer]
          .discard.cards .. " Card(s)"

      -- Played Cards
      for i, card in ipairs(Game.players[Game.activePlayer]
            .playedCards.cards) do
            -- if not PlayedCards.cards[i] then goto continue end
            -- card.scale = 0.6
            -- Increment Row when edge of screen reached

            card.y = UI.playedCards.y + 50 +
                ((math.modf((i * card.w) / love.graphics.getWidth())) * card.h)
            --     ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * card.h * card.scale)

            -- Reset to 0 X when row incremented
            card.x = UI.playedCards.x + (6 * i) + card.w * (i - 1) -
                ((math.modf((i * card.w) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w) * card.w))


            card.x = (6 * i) + card.w * card.scale * (i - 1) -
                ((math.modf((i * card.w * card.scale) / love.graphics.getWidth())) * (math.modf(love.graphics.getWidth() / card.w * card.scale) * card.w * card.scale))
            ::continue::
      end

      -- Hand and cards in Hand
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("fill", UI.hand.x, UI.hand.y, UI.hand.w, UI.hand.h)

      for i = 1, #Game.players[Game.activePlayer].hand.cards, 1 do
            if not Game.players[Game.activePlayer].hand.cards[i] then goto continue end
            if Game.players[Game.activePlayer].hand.cards[i].title == "spacer" then goto continue end
            Game.players[Game.activePlayer].hand.cards[i].x = UI.hand.x +
                Game.players[Game.activePlayer].hand.cards[i].w * (i - 1) + (8 * i)
            Game.players[Game.activePlayer].hand.cards[i].y = UI.hand.y + 5
            ::continue::
      end

      -- Draw Cards
      for index, value in ipairs(GameObjects) do
            value:draw()
      end

      -- Turn stats
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Buying Power: " .. Game.players[Game.activePlayer].buyingPower, 0, 15)

      -- Discard indicator
      if Game.cursorMode == CursorMode.discard then
            love.graphics.print("Choose " .. Game.discardCount .. " more card(s) to discard.", 500, 400)
      end

      -- End turn button
      love.graphics.rectangle("fill", UI.endTurnButton.x, UI.endTurnButton.y, UI.endTurnButton.w, UI.endTurnButton.h)
      love.graphics.setColor(0, 0, 0)
      love.graphics.print("END TURN", UI.endTurnButton.x + 5, UI.endTurnButton.y)


      -- Debug stuff
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Cards in hand: " ..
            #Game.players[Game.activePlayer].hand.cards ..
            ", Cards in Play: " ..
            #Game.players[Game.activePlayer].playedCards.cards ..
            ", Cards in Deck: " ..
            #Game.players[Game.activePlayer].deck.cards ..
            ", Cards in Discard: " .. #Game.players[Game.activePlayer].discard.cards
            .. ", Active player: " .. Game.activePlayer
            .. ", Game Object Count: " .. #GameObjects
            .. ", Score: " .. Util.activePlayer().points
            .. ", Points Pool: " .. Game.pointsPool
            .. ", Cursor Mode: " .. Game.cursorMode)
      local s = "DecK: "
      for i = 1, #Game.players[Game.activePlayer].deck.cards, 1 do
            s = s .. Game.players[Game.activePlayer].deck.cards[i].title .. " "
      end
      love.graphics.print(s, 0, 30)
end

function love.mousepressed(x, y, button, istouch)
      if button ~= 1 then
            return
      end
      local p = Game.players[Game.activePlayer]
      local Hand = p.hand
      local Discard = p.discard
      if Game.cursorMode == CursorMode.clickInteraction then
            for index, obj in ipairs(Game.clickInteractionTargets) do
                  if Util.checkMouseOver(x, y, obj) then
                        io.write("Interaction click:  " .. obj.title .. ".\n")
                        Game.clickInteractionCallback(obj)
                        Game.cursorMode = CursorMode.none
                        return
                  end
            end
      end
      for i = 1, #Hand.cards, 1 do
            if not Hand.cards[i] then goto continue end
            if Util.checkMouseOver(x, y, Hand.cards[i]) then
                  local selectedCard = Hand.cards[i]
                  if Game.cursorMode == CursorMode.none then
                        -- Hand.cards[i].dragging = true
                        cursorCard = table.remove(Hand.cards, i)
                        -- cursorCard = selectedCard:new()
                        cursorCard.highlight = false
                        io.write("Picked up " .. cursorCard.title .. ".\n")
                        cursorCardID = i
                        -- cursorCard.x = x - cursorCard.w
                        -- cursorCard.y = y - cursorCard.h
                        goto continue
                  elseif Game.cursorMode == CursorMode.discard then
                        io.write("Discarding " .. selectedCard.title .. ".\n")
                        Hand:discard(i)
                        Game.discardCount = Game.discardCount - 1
                        table.insert(Game.discardingList, selectedCard)
                        if Game.discardCount <= 0 then
                              Game.discardCallback(Game.discardingList)
                              if Game.cursorMode == CursorMode.discard then
                                    Game.cursorMode = CursorMode.none
                              end
                              for index, value in ipairs(Hand.cards) do
                                    value.highlight = false
                                    value.highlightColour = UI.colours.HIGHLIGHT
                              end
                              Game.discardingList = {}
                              Game.discardCallback = function()
                                    return
                              end
                        end
                  end
            end
            ::continue::
      end
      for i = 1, #Shop, 1 do
            if #Shop[i] > 0 and Util.checkMouseOver(x, y, Shop[i][1]) then
                  if p.buyingPower >= Shop[i][1].buyCost then
                        p.buyingPower = p.buyingPower - Shop[i][1].buyCost
                        p.points = p.points + Shop[i][1].buyCost
                        Game.pointsPool = math.max(Game.pointsPool - Shop[i][1].buyCost, 0)
                        Shop[i][1].targetX = p.discard.graphic.x
                        Shop[i][1].targetY = p.discard.graphic.y
                        Shop[i][1].hideOnDestination = true
                        table.insert(Discard.cards, table.remove(Shop[i],1))
                  end
            end
      end
      if Util.checkMouseOver(x, y, UI.endTurnButton) then
            Game.endTurn()
      end
end

function love.mousereleased(x, y, button, istouch)
      -- Iterate backwards so removing doesn't skip items
      local p = Game.players[Game.activePlayer]
      local Hand = p.hand
      local Discard = p.discard
      if cursorCard then
            local canAfford = true
            if cursorCard.playCost > 0 then
                  local handTotalValue = 0
                  for index, card in ipairs(Hand.cards) do
                        handTotalValue = handTotalValue + card.barterValue
                  end
                  if cursorCard.playCost > handTotalValue then
                        canAfford = false
                  end
            end
            if (cursorCard.y + cursorCard.h / 2) < love.graphics.getHeight() / 3 * 2 and cursorCard.playable and canAfford then
                  cursorCard:play()
            else
                  cursorCard.dragging = false
                  local indexToMove = math.modf(x / cursorCard.w) + 1 -- Add one becuase lua arrays are 1-indexed
                  if indexToMove > #Hand.cards + 1 then indexToMove = #Hand.cards + 1 end
                  -- table.insert(Hand.cards, indexToMove, cursorCard:new())
                  table.insert(Hand.cards, indexToMove, cursorCard)
                  io.write("Dropped " .. cursorCard.title .. ".\n")
            end
            for i = #Hand.cards, 1, -1 do
                  if Hand.cards[i] and Hand.cards[i].title == "spacer" then
                        -- table.remove(Hand.cards, i)
                        -- Hand.hasSpacer = false
                        Hand.cards[i]:destroy()
                        Hand.spacerIndex = -1
                  end
            end
      end
      cursorCard = nil
      cursorCardID = nil
end

function love.mousemoved(x, y, dx, dy)
      local p = Game.players[Game.activePlayer]
      local Hand = p.hand
      if cursorCard then
            cursorCard.x = cursorCard.x + dx
            cursorCard.y = cursorCard.y + dy
            cursorCard.targetX = x
            cursorCard.targetY = y

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
                        if Util.checkMouseOver(x, y, value) then
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
