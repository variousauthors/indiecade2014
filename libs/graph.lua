LinkedList = require('libs/linked_list')

local oid = 0

local Graph = function ()
    local id = oid
    local oid = oid + 1

    local instance = {}
    local adjacency_list = {}
    local size = 0 -- instance scope count of vertices
    local uid = 0 -- instance scope id for vertices

    local getSize = function () return size end

    local insert = function (...)
        for i, value in pairs({ ... }) do
            local node = {
                neighbours = LinkedList(),
                data = value,
                nid = uid
            }

            adjacency_list[uid] = node

            uid = uid + 1
            size = size + 1
        end
    end

    local sample = function ()
        local index = love.math.random(0, getSize() - 1)
        local node = adjacency_list[index]

        return {
            data = node.data,
            nid = node.nid
        }
    end

    -- returns the first node matching all params in both key and value
    local find = function (params)
        local node

        for i, n in pairs(adjacency_list) do
            local found = false

            for k, v in pairs(params) do
                if n.data[k] ~= nil and n.data[k] == v then
                    found = true
                else
                    found = false
                end
            end

            if found == true then
                node = {
                    data = n.data,
                    nid = n.nid
                }
            end
        end

        return node
    end

    -- return all nodes matching all params in both key and value
    local where = function (...)
        local nodes = {}

        for i, params in pairs({ ... }) do
            local node

            for i, n in pairs(adjacency_list) do
                local found = false

                for k, v in pairs(params) do
                    if n.data[k] ~= nil and n.data[k] == v then
                        found = true
                    else
                        found = false
                    end
                end

                if found == true then
                    table.insert(nodes, {
                        data = n.data,
                        nid = n.nid
                    })
                end
            end
        end

        return nodes
    end

    local toString = function ()
        local str = ""
        str = str .. "[\n"

        for i, v in pairs(adjacency_list) do
            local node = adjacency_list[i]
            local it = node.neighbours.getIterator()

            str = str .. "{ data = " .. node.data .. ", neighbours = ["
            while (it.hasNext()) do
                local nid = it.getNext().getData()
                local node = adjacency_list[nid]

                str = str .. "data = " .. node.data .. ", "
            end

            str = str .. "]"
            str = str .. " }"

            str = str .. "\n"
        end

        str = str .. "]"

        return str
    end

    local add_edge = function (n1, n2)
        local node1 = adjacency_list[n1.nid]
        local node2 = adjacency_list[n2.nid]

        if node1.neighbours.doesInclude(n2.nid) then
            -- NOP the edge exists
        else
            node1.neighbours.append(n2.nid)
        end
    end

    -- fully connects the given nodes
    local connect = function (...)
        local from_set = { ... }
        local to_set = { ... }

        for i, n1 in pairs(from_set) do
            for j, n2 in pairs(to_set) do
                if n1.nid ~= n2.nid then
                    add_edge(n1, n2)
                    add_edge(n2, n1)
                end
            end

            -- remove n1 from the to_set
            table.remove(to_set, 1)
        end
    end

    local doesInclude = function (data)
        local includes = false

        for i, v in pairs(adjacency_list) do
            if v.data == data then
                includes = true
            end
        end

        return includes
    end

    local count = function (data)
        -- return a count of vertices matching the given
        local n = 0

        for i, v in pairs(adjacency_list) do
            if v.data == data then
                n = n + 1
            end
        end

        return n
    end
    
    instance.connect = connect
    instance.getSize = getSize
    instance.insert = insert
    instance.sample = sample
    instance.find = find
    instance.where = where
    instance.toString = toString
    instance.doesInclude = doesInclude
    instance.count = count

    return instance
end

print("GRAPH DIAGNOSTICS")

local g1 = Graph() -- default weight

-- insert nodes by value
g1.insert("v1") -- insert one node
assert(g1.doesInclude("v1") == true)

g1.insert("v2", "v3", "v4") -- or many nodes
assert(g1.doesInclude("v2") == true)
assert(g1.doesInclude("v3") == true)
assert(g1.doesInclude("v4") == true)

g1.insert("v1") -- duplicate values OK
assert(g1.count("v1") == 2)

-- these methods return copies that can be used to make edges
local n1 = g1.sample() -- get a node
assert(g1.doesInclude(n1.data) == true)

g1.insert({ v5 = "v5" })

local n2 = g1.find({ v5 = "v5" }) -- a node having the given keys and values
assert(g1.doesInclude(n2.data) == true)
assert(n2.data["v5"] == "v5")

g1.insert({ v5 = "v5", v6 = "v6" })

local n3 = g1.find({ v5 = "v5", v6 = "v6" }) -- having _all_ the key value pairs
assert(g1.doesInclude(n3.data) == true)
assert(n3.data["v5"] == "v5")
assert(n3.data["v6"] == "v6")

local n4 = g1.find({ v5 = "v5", vx = "vx" }) -- a partial match returns nil
assert(n4 == nil)

local nodes1 = g1.where({ v5 = "v5" }) -- table of all nodes having the keys and values
assert(#nodes1 == 2)

local nodes2 = g1.where({ v5 = "v5", v6 = "v6" }) -- table of all nodes having the keys and values
assert(#nodes2 == 1)

--  g1.edge(n1, n2) -- an edge from n1 to n2 (default weight)
--  g1.edge(n2, n1, 4) -- the reverse edge (weighted)
--  g1.hasEdge(n1, n2) -- test edge
--  e1 = g1.getEdge(n1, n2) -- returns the edge if it exists

--  neighbours = g1.getNeighbours(n1) -- nodes with edges from n1
--  incident_set = g1.getIncidentSet(n1) -- nodes with edges going to n1
--  connected = g1.getConnectedSet(n1) -- incident nodes and neighbour nodes

--  w = e1.weight

--  g1.remove(e1) -- removes the edge
--  g1.remove(n1) -- removed the node (and any related edges)

--  g1.connect(n1, n2) -- add an edge from n1 to n2, and from n2 to n1
--  g1.connect(nodes1) -- fully connect the given nodes

--  g2 = g1.copy() -- fully copy the graph

--  print("GRAPH ALL PASS")

return Graph
