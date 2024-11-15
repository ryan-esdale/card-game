local debugFile = io.open('debug.txt', 'a+')
io.output(debugFile)

local CardTemplate = require('cards.template')

local CARDS = {
      createCardFunc = function(template)
            return CardTemplate:new(template)
      end
}

local d = love.filesystem.getDirectoryItems('cards')
for index, v in ipairs(d) do
      local title = string.sub(v, 1, #v - 4)
      if string.sub(title, 1, 5) ~= 'debug' and string.sub(title, 1, 3) ~= 'img' then
            CARDS[title] = require('cards.' .. title)
      end
end

-- Dummy Test Card
local test_card = CardTemplate:new()
CARDS['testCard'] = test_card


return CARDS
