local outpost = {
      type = 'turnStart',
      effect = function()
            local a = require('cards.asteroid'):new()
            a.ethereal = true
            Util.activePlayer().hand:addCard(a)
      end
}

return outpost
