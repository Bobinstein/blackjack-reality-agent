-- Configure this to the process ID of the world you want to send chat messages to, currently the blackjack process is hard coded for the below world id
WORLD_ID = 'RXeJvxYtBVdZZ8xR9JJEUtNBXqwQmOrTZthiQL-bZD4'
BlackJackProcess = '1NroE5BWvZXvoSuQLuXRvRPaHTLZS940zgAxwG_1mcA'

-- Enter in world process
-- RealityEntitiesStatic = {
--   ['zsU5NxCo8WbpyLCqXrckjmXfP0PWpAGzo1E-W_iegbI'] = {
--       Position = { 11, 8 },
--       Type = 'Avatar',
--       Metadata = {
--           DisplayName = "LLama-Jack",
--           SkinNumber = 9,
--           Interaction = {
--               Type = "SchemaExternalForm",
--               Id = "BlackJack",
--           }
--       }
--   }
-- }


local json = require('json')



Cards = {
  -- Spades
  ["A of Spades"] = "🂡",
  ["2 of Spades"] = "🂢",
  ["3 of Spades"] = "🂣",
  ["4 of Spades"] = "🂤",
  ["5 of Spades"] = "🂥",
  ["6 of Spades"] = "🂦",
  ["7 of Spades"] = "🂧",
  ["8 of Spades"] = "🂨",
  ["9 of Spades"] = "🂩",
  ["10 of Spades"] = "🂪",
  ["J of Spades"] = "🂫",
  ["Q of Spades"] = "🂭",
  ["K of Spades"] = "🂮",

  -- Hearts
  ["A of Hearts"] = "🂱",
  ["2 of Hearts"] = "🂲",
  ["3 of Hearts"] = "🂳",
  ["4 of Hearts"] = "🂴",
  ["5 of Hearts"] = "🂵",
  ["6 of Hearts"] = "🂶",
  ["7 of Hearts"] = "🂷",
  ["8 of Hearts"] = "🂸",
  ["9 of Hearts"] = "🂹",
  ["10 of Hearts"] = "🂺",
  ["J of Hearts"] = "🂻",
  ["Q of Hearts"] = "🂽",
  ["K of Hearts"] = "🂾",

  -- Diamonds
  ["A of Diamonds"] = "🃁",
  ["2 of Diamonds"] = "🃂",
  ["3 of Diamonds"] = "🃃",
  ["4 of Diamonds"] = "🃄",
  ["5 of Diamonds"] = "🃅",
  ["6 of Diamonds"] = "🃆",
  ["7 of Diamonds"] = "🃇",
  ["8 of Diamonds"] = "🃈",
  ["9 of Diamonds"] = "🃉",
  ["10 of Diamonds"] = "🃊",
  ["J of Diamonds"] = "🃋",
  ["Q of Diamonds"] = "🃍",
  ["K of Diamonds"] = "🃎",

  -- Clubs
  ["A of Clubs"] = "🃑",
  ["2 of Clubs"] = "🃒",
  ["3 of Clubs"] = "🃓",
  ["4 of Clubs"] = "🃔",
  ["5 of Clubs"] = "🃕",
  ["6 of Clubs"] = "🃖",
  ["7 of Clubs"] = "🃗",
  ["8 of Clubs"] = "🃘",
  ["9 of Clubs"] = "🃙",
  ["10 of Clubs"] = "🃚",
  ["J of Clubs"] = "🃛",
  ["Q of Clubs"] = "🃝",
  ["K of Clubs"] = "🃞"
}


Llama = Llama or nil

LLAMA_TOKEN_PROCESS = 'pazXumQI-HPH7iFGfTC-4_7biSnqz_U67oFAGry5zUY'
LLAMA_TOKEN_DENOMINATION = 12
LLAMA_TOKEN_MULTIPLIER = 10 ^ LLAMA_TOKEN_DENOMINATION
LLAMA_JOKE_PRICE_WHOLE_MIN = 1
LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY = LLAMA_JOKE_PRICE_WHOLE_MIN * LLAMA_TOKEN_MULTIPLIER


function StartGameSchema()
  return [[
{
"type": "object",
"required": [
  "Action",
  "Recipient",
  "Quantity",
  "X-Note"
],
"properties": {
  "Action": {
    "type": "string",
    "const": "Transfer"
  },
  "Recipient": {
    "type": "string",
    "const": "]] .. BlackJackProcess .. [["
  },
  "Quantity": {
    "type": "number",
    "const": ]] .. LLAMA_JOKE_PRICE_WHOLE_MIN_QUANTITY .. [[
  },
  "X-Note": {
    "type": "string",
    "const": "LlamaMessage"
  }
}
}
]]
end

function PlayHandSchema()
  return [[
{
"type": "object",
"required": [
  "Action",
  "X-Note"
],
"properties": {
  "Action": {
  "title": "Action",
    "type": "string",
    "enum": ["Hit", "Stay"]
  },
  "X-Note": {
    "type": "string",
    "const": "LlamaMessage"
  }
}
}
]]
end

Handlers.add(
  'SchemaExternal',
  Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
  function(msg)
    print('SchemaExternal')
    ao.send({
      Target = BlackJackProcess,
      Tags = {
        Action = 'showState',
        Caller = msg.From,
      },
    })
    print("The message should have sent")
  end
)


Handlers.add(
  "StateMessage",
  Handlers.utils.hasMatchingTag('Action', 'BlackJackMessage'),
  function(msg)
    print("BlackJack state received.")

    local account = msg.Player
    local truncatedAccount = account:sub(1, 3) .. "..." .. account:sub(-3)
    local messageData = msg.Data

    -- Function to calculate hand value
    local function calculateHandValue(hand)
      local value = 0
      local aces = 0

      for _, card in ipairs(hand) do
        if card.value == "A" then
          value = value + 11
          aces = aces + 1
        elseif card.value == "K" or card.value == "Q" or card.value == "J" or card.value == "10" then
          value = value + 10
        else
          value = value + tonumber(card.value)
        end
      end

      while value > 21 and aces > 0 do
        value = value - 10
        aces = aces - 1
      end

      return value
    end

    local function formatHand(hand)
      local handStr = ""
      for i, card in ipairs(hand) do
        local cardKey = card.value .. " of " .. string.sub(card.suit, 1, 1):upper() .. string.sub(card.suit, 2):lower()
        local unicodeCard = Cards[cardKey] or cardKey
        handStr = handStr .. unicodeCard
        if i < #hand then
          handStr = handStr .. ", "
        end
      end
      return handStr
    end


    local function getActiveHand(state)
      local activeHandIndex = state.activeHandIndex or 1
      return state.hands[activeHandIndex]
    end


    if msg.Data == "This game has ended" or msg.Data == "You have no active game, start one by sending a bet" then
      local stateDescription
      if msg.State then
        local state = json.decode(msg.State)

        -- Dealer's hand
        local dealerHand = state.dealerCards
        local dealerValue = calculateHandValue(dealerHand)

        -- Player's active hand
        local activeHand = getActiveHand(state)
        local playerHand = activeHand.cards
        local playerValue = calculateHandValue(playerHand)


        stateDescription = string.format(
          "Dealer's Hand: %s (Value: %d)\nYour Hand: %s (Value: %d)\n\n%s",
          formatHand(dealerHand),
          tonumber(dealerValue),
          formatHand(playerHand),
          tonumber(playerValue),
          "This game has ended. Start a new game by transferring 1 $Llama."
        )
      else
        stateDescription = msg.Data .. " Start a new game by transferring 1 $Llama"
      end


      Send({
        Target = account,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          BlackJack = {
            Target = LLAMA_TOKEN_PROCESS,
            Title = "Deal me in",
            Description = stateDescription,
            Schema = { Tags = json.decode(StartGameSchema()) },
          },
        })
      })


      Send({
        Target = WORLD_ID,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = "Llama-Jack"
        },
        Data = truncatedAccount .. " " .. msg.Data
      })
    else
      local state = json.decode(msg.State)

      -- Dealer's hand
      local dealerHand = state.dealerCards
      local dealerValue = calculateHandValue(dealerHand)

      -- Player's active hand
      local activeHand = getActiveHand(state)
      local playerHand = activeHand.cards
      local playerValue = calculateHandValue(playerHand)

      local description = string.format(
        "Dealer's Hand: %s (Value: %d)\nYour Hand: %s (Value: %d)",
        formatHand(dealerHand),
        tonumber(dealerValue),
        formatHand(playerHand),
        tonumber(playerValue)
      )

      print("active game")
      Send({
        Target = account,
        Tags = { Type = "SchemaExternal" },
        Data = json.encode({
          BlackJack = {
            Target = BlackJackProcess,
            Title = "Play Hand",
            Description = description,
            Schema = { Tags = json.decode(PlayHandSchema()) }
          }
        })
      })


      local chatMessage

      if not state.isHistoric then
        chatMessage = truncatedAccount .. " current game status: " .. description
      else
        chatMessage = truncatedAccount .. " final state of last game: " .. description
      end


      Send({
        Target = WORLD_ID,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = "Llama-Jack"
        },
        Data = chatMessage
      })
    end

    print("Schema sent.")
  end
)
