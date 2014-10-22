LinkedList = require('libs/linked_list')

local oid = 0

local Graph = function ()
    local id = oid
    local oid = oid + 1

    local instance = {}
    local adjacency_list = {}
    local size = 0
    local nid = 0

    local getSize = function () return size end

    local insert = function (value)
        local node = {
            neighbours = LinkedList(),
            data = value,
            nid = nid
        }

        adjacency_list[nid] = node

        nid = nid + 1
        size = size + 1
    end

    local sample = function ()
        local index = love.math.random(0, getSize() - 1)
        local node = adjacency_list[index]

        return {
            data = node.data,
            nid = node.nid
        }
    end
    
    instance.getSize = getSize
    instance.insert = insert
    instance.sample = sample

    return instance
end

--  print("GRAPH DIAGNOSTICS")

--  g1 = Graph() -- default weight

--  -- insert nodes by value
--  g1.insert(v1) -- insert one node
--  g1.insert(v2, v3, v4) -- or many nodes
--  g1.insert(v1) -- duplicate values OK

--  -- these methods return copies that can be used to make edges
--  n1 = g1.sample() -- get a node
--  n2 = g1.find({ key = value }) -- a node having the given keys and values
--  nodes1 = g1.where({ key = value }) -- LL of all nodes having the keys and values

--  d = n1.data
--  neighbours = g1.getNeighbours(n1) -- nodes with edges from n1
--  incident_set = g1.getIncidentSet(n1) -- nodes with edges going to n1
--  connected = g1.getConnectedSet(n1) -- incident nodes and neighbour nodes

--  g1.edge(n1, n2) -- an edge from n1 to n2 (default weight)
--  g1.edge(n2, n1, 4) -- the reverse edge (weighted)
--  g1.hasEdge(n1, n2) -- test edge
--  e1 = g1.getEdge(n1, n2) -- returns the edge if it exists

--  w = e1.weight

--  g1.remove(e1) -- removes the edge
--  g1.remove(n1) -- removed the node (and any related edges)

--  g1.connect(n1, n2) -- add an edge from n1 to n2, and from n2 to n1
--  g1.connect(nodes1) -- fully connect the given nodes

--  g2 = g1.copy() -- fully copy the graph

--  print("GRAPH ALL PASS")

return Graph
