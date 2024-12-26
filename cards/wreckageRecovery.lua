local CardTemplate = require('cards.template')

local greenCard = CardTemplate:new()


-- Green that costs 2 and draws 4
greenCard.title = "Wreckage Recovery"
greenCard.text = "Gain 2 Credits\nBurn 1 card from the market"
greenCard.color = { 1, 0, 1 }
greenCard.buyCost = 0
greenCard.playCost = 2
greenCard.play = function(self)
      Game.discardCallback = function()

            Util.activePlayer().buyingPower = Util.activePlayer().buyingPower + 2
            for index, shop in ipairs(Shop) do
                  table.insert(Game.clickInteractionTargets, shop[1])
                  shop[1].highlight = true
            end
            Game.cursorMode = CursorMode.clickInteraction

            Game.clickInteractionCallback = function(targetCard)
                  
                  for index, card in ipairs(Game.clickInteractionTargets) do
                        card.highlight = false
                  end
                  Game.clickInteractionTargets = {}
                  targetCard:destroy()
                  -- Game.cursorMode = CursorMode.none
            end
      end

      CardTemplate.play(self)
end

return greenCard
