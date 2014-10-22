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

    instance.getSymbol = function ()
        local symbol = nil

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
        local symbol = active.getSymbol()

        if symbol == nil then
            print(active.getName() .. ": " .. "...")
        else
            print(active.getName() .. ": " .. symbol)
        end

        -- advance to the next speaker
        active = getNext()
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

