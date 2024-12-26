local CardTemplate = require('cards.template')

local greenCard = CardTemplate:new()


-- Green that costs 2 and draws 4
greenCard.title = "Raider Ship"
greenCard.text = "Steal 1 Point from each opponent."
greenCard.color = { 1, 0, 0 }
greenCard.buyCost = 0
greenCard.playCost = 1
greenCard.play = function(self)
      Game.discardCallback = function()
            -- Game.players[Game.activePlayer].hand:drawCard(4)
            local stolenPoints = 0
            for index, player in ipairs(Game.players) do
                  if player.ID ~= Game.activePlayer then
                        if player.points > 0 then      
                              player.points = player.points-1
                              stolenPoints = stolenPoints + 1
                        end
                  end                  
            end
            Util.activePlayer().points = Util.activePlayer().points + stolenPoints
            
      end

      CardTemplate.play(self)
end

return greenCard
