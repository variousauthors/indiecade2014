-- an update function
-- two or more participants
-- every few seconds, the conversation runs its update function

local masterSymbolGraph = require('game/symbols')

-- every folk has access to some nodes from the Symbol graph
Folk = function (name)
    local instance = {}
    local symbols = Graph()

    -- folk needs a partial symbol graph
    -- insert a node randomly,
    -- insert another node randomly and check if there are any
    -- edges to any existing nodes: if so insert those edges
    local copyNode = function (vertex)
        -- get a node from the graph
        -- if that node is not in the local copy
        -- insert that node
        -- now run hasEdge on each pair with that node
        -- if hasEdge is true, connect the pair

        local insert = false

        -- insert the symbol if it isn't already in the graph
        if symbols.doesInclude(vertex.data) then
            if symbols.count(vertex.data) < masterSymbolGraph.count(vertex.data) then
                insert = true
            end
        else
            insert = true
        end

        if insert == true then
            local neighbours = masterSymbolGraph.getConnectedSet(vertex)

            -- insert the symbol and map to our local copy
            symbols.insert(vertex.data)
            vertex = symbols.find(vertex.data)

            -- update the edges to reflect the mastersymbolgraph
            -- get the neighbours from the master graph
            for i, v in pairs(neighbours) do
                v = symbols.find(v.data) -- local copy

                -- if any of those neighbours exist in the local graph
                if v ~= nil then
                    symbols.connect(vertex, v)
                end
            end
        end
    end

    for i = 1, love.math.random(3, 5) do
        copyNode(masterSymbolGraph.sample())
    end

    love.debug.print(symbols.toString())

    local getSymbol = function (current_symbol)
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

    local getName = function () return name end

    instance.getSymbol = getSymbol
    instance.getName = getName

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

