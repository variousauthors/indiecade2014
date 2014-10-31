-- an update function
-- two or more participants
-- every few seconds, the conversation runs its update function

local masterSymbolGraph = require('game/symbols')

-- every folk has access to some nodes from the Symbol graph
local folk_size = 30

Folk = function (name, x, y)
    local instance = {}
    local symbols = Graph()

    -- folk needs a partial symbol graph
    -- insert a node randomly,
    -- insert another node randomly and check if there are any
    -- edges to any existing nodes: if so insert those edges
    local copyNode = function (vertex)
        local insert = false

        -- insert the symbol if it isn't already in the graph
        if symbols.doesInclude(vertex.data) then

            -- TODO because we find by value, we can't actually have duplicate symbols
            -- in the graph, so we don't need this edge case
            --  if symbols.count(vertex.data) < masterSymbolGraph.count(vertex.data) then
            --      -- not enough in the graph
            --      insert = true
            --  end
        else
            -- not in the graph
            insert = true
        end

        -- TODO one consequence of what we are doing here, is that the vertices
        -- must be unique by value, which is not what I originally intended.
        -- I can't really think of a reason we would want the verts not to be
        -- unique at the moment, though...
        if insert == true then
            symbols.insert(vertex.data)

            local neighbours = masterSymbolGraph.getConnectedSet(vertex)

            -- map to our local copy
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
    local getX = function () return x end
    local getY = function () return y end

    local draw = function ()
        love.graphics.circle("fill", x, y, folk_size)
    end

    instance.getSymbol = getSymbol
    instance.getName = getName
    instance.getX = getX
    instance.getY = getY
    instance.draw = draw

    return instance
end

Conversation = function (folks)
    local instance = { }

    local talking_stick = folks.getIterator()
    local active = talking_stick.getNext().getData()
    local current_symbol = nil

    local topic = {
        width = 100,
        height = 77,
        symbol = nil,
        members = {}
    }

    -- folk are the people in the conversation
    -- members are the folk speaking the current symbol (usually one)
    local topic_draw = function ()
        if topic.symbol == nil then return end

        -- determine the center point between the folk
        -- if there are just two folk, offset up by height and a half
        -- of a member

        -- we don't need to iterate to find the center,
        -- this should be calculated whenever folk join the conversation
        -- for now we will use an arbitrary point on the screen
        local center = { x = 200 + folk_size*1.5, y = 200 - folk_size*3 }
        topic.origin = {
            x = center.x - topic.width/2,
            y = center.y - topic.height/2
        }

        -- draw a rectangle TODO rounded corners
        love.graphics.rectangle("fill", topic.origin.x, topic.origin.y, topic.width, topic.height)

        -- draw a line from the center of the rectangle to each
        for i, member in pairs(topic.members) do
            love.graphics.line(center.x, center.y, member.getX(), member.getY())
        end

        -- put the symbol in the rectangle
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(topic.symbol, center.x, center.y, 0, "center")
        love.graphics.setColor(255, 255, 255)
    end

    topic.draw = topic_draw

    local getNext = function ()
        local result = nil

        if (talking_stick.hasNext()) then
            result = talking_stick.getNext().getData()
        else
            talking_stick = folks.getIterator()
            result = talking_stick.getNext().getData()
        end

        return result
    end

    local advance = function ()
        -- the active speaker acts
        local symbol = active.getSymbol(current_symbol)

        if symbol == nil then
            -- TODO this should end the conversation entirely
            symbol = "..."
            topic.members = { active }
            -- print(active.getName() .. ": " .. "...")
        elseif symbol == current_symbol then
            -- the speaker is added to the current speach bubble (topic)
            table.insert(topic.members, active)
            -- print(active.getName() .. ": " .. symbol)
        else
            -- the topic drops to just one speaker
            topic.members = { active }
            -- print(active.getName() .. ": " .. symbol)
        end

        -- advance to the next speaker
        active = getNext()
        current_symbol = symbol
        topic.symbol = symbol
    end

    local draw = function ()
        -- draw the topic
        -- a rectangle that hange above the folk,
        -- with a triangle pointing at the speaker
        -- multipler triangles if multiple speakers
        topic.draw()

        -- TODO conversation should not be responsible for drawing folk
        -- there should be a folk manager somewhere
        local it = folks.getIterator()

        while (it.hasNext()) do
            local folk = it.getNext().getData()
            folk.draw()
        end
    end

    local interval = .5
    local timer = 0
    local update = function (dt)
        timer = timer + dt
        if timer > interval then
            advance()
            timer = timer - interval
        end
    end

    instance.update = update
    instance.draw = draw

    return instance
end

local unit = 200
folks = LinkedList()
folks.append(Folk("ZIGS", unit, unit))
folks.append(Folk("NOMOON", unit + 3*folk_size, unit))

c = Conversation(folks)

