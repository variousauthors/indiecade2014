-- an update function
-- two or more participants
-- every few seconds, the conversation runs its update function

local symbolGraph = require('game/symbols')

-- every folk has access to some nodes from the Symbol graph
Folk = function (name)
    local instance = {}
    local symbols = Graph()

    for i = 1, love.math.random(3, 5) do
        symbols.insert(symbolGraph.sample().data)
    end

    instance.getSymbol = function (current_symbol)
        local symbol = nil

        -- the speaker will either:
        --   if there is a related symbol in her graph, declare one of them
        --   repeat the current symbol (which "expands" the conversation)
        --   declare a terminal symbol, which causes them to leave the conversation
        --   LATER
        --   maybe if the terminal symbol comes up, but the relationship
        --     is strong, she declares a new symbol: (from the graph, her own, or a question mark)
        --     question mark prompts the next folk to declare their symbol
        i = love.math.random(1, 10) % 3

        if i ~= 0 then
            symbol = symbols.sample().data
        end

        return symbol
    end

    instance.getName = function () return name end

    return instance
end

Conversation = function (folks)
    local instance = { }

    local iterator = folks.getIterator()
    local active = iterator.getNext().getData()
    local current_symbol = nil

    local getNext = function ()
        local result = nil

        if (iterator.hasNext()) then
            result = iterator.getNext().getData()
        else
            iterator = folks.getIterator()
            result = iterator.getNext().getData()
        end

        return result
    end

    local advance = function ()
        -- the active speaker acts
        local symbol = active.getSymbol(current_symbol)

        if symbol == nil then
            print(active.getName() .. ": " .. "...")
        else
            print(active.getName() .. ": " .. symbol)
        end

        -- advance to the next speaker
        active = getNext()
        current_symbol = symbol
    end

    instance.update = function (dt)
        -- every few seconds, advance the conversation

        advance()
    end

    return instance
end

folks = LinkedList()
folks.append(Folk("ZIGS"))
folks.append(Folk("NOMOON"))

c = Conversation(folks)

