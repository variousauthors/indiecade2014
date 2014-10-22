local Node = function (_data, _link)

    local setNext = function (link)
        _link = link
    end

    local getNext = function ()
        return _link
    end

    local setData = function (data)
        _data = data
    end

    local getData = function ()
        return _data
    end

    return {
        setNext = setNext,
        getNext = getNext,
        setData = setData,
        getData = getData
    }
end

-- goal is to make an adjacency list, but I can't remember what those are like
-- an array of n linked lists, each node represents an adjacency? It should
-- contain data like { x, y, n } where n is the index of the adjacent vertex
-- and x, y are data? Then it links to the next adjacency? I think that's
-- right. So actually, we aren't representing a graph in memory. OK?
local LinkedList = function ()
    local self = {}

    local head, tail, length

    -- iterator should have "hasNext" and "next"
    local getIterator = function ()
        -- an imaginary node pointing at the head
        local p = Node(nil, self.head)

        local getNext = function ()
            local n = p.getNext()
            p = n

            return n
        end

        local hasNext = function ()
            return p.getNext() ~= nil
        end

        return {
            hasNext = hasNext,
            getNext = getNext
        }
    end

    local getLength = function ()
        return self.length
    end

    -- returns a list of one element
    local unit = function (data)
        self.head   = Node(data, nil)
        self.tail   = self.head
        self.length = 1

        return self
    end

    -- returns the empty list
    local init = function ()
        self.head, self.tail = nil
        self.length = 0

        return self
    end

    local append = function (data)
        if self.length == 0 then return unit(data) end

        local n = Node(data, nil)
        self.length = self.length + 1

        self.tail.setNext(n)
        self.tail = n

        return self
    end

    local push = function (data)
        if self.length == 0 then return unit(data) end

        local n = Node(data, self.head)
        self.length = self.length + 1

        self.head = n

        return self
    end

    -- returns the last element in the list
    local unshift = function ()
        -- throw if we pop from an empty list
        if self.length == 0 then return self.head.getData() end

        if self.length == 1 then
            local n = self.head.getData()
            init()

            return n
        end

        local it = getIterator()
        local p, q = it.getNext(), nil

        while (it.hasNext()) do
            q = it.getNext()

            if q ~= self.tail then
                p = q
            end
        end

        p.setNext(nil)
        self.tail = p
        self.length = self.length - 1

        return q.getData()
    end

    local pop = function ()
        -- throw if we pop from an empty list
        if self.length == 0 then return self.head.getData() end

        if self.length == 1 then
            local n = self.head.getData()
            init()

            return n
        end

        local n = self.head
        self.head    = self.head.getNext()
        self.length  = self.length - 1

        return n.getData()
    end

    local peek = function ()
        return self.head.getData()
    end

    local each = function (callback)
        local iterator = getIterator()
        local index = 0

        while (iterator.hasNext()) do
            local node = iterator.getNext()
            index = index + 1

            callback(node, index)
        end
    end

    local isEmpty = function ()
        return getLength() == 0
    end

    self.getLength   = getLength
    self.getIterator = getIterator
    self.append      = append
    self.push        = push
    self.pop         = pop
    self.peek        = peek
    self.each        = each
    self.init        = init
    self.unit        = unit
    self.isEmpty     = isEmpty

    return self.init()
end

print("NODE DIAGNOSTICS")
local a, b, c, d, e, p, l, i, data, count, did_run, q

-- can create a node
a = Node({ stuff = "hey", nil })
assert(a.getData() ~= nil)
assert(a.getNext() == nil)

-- can set the link to another node
a.setNext(Node({ stuff = "nil", nil }))
assert(a.getData() ~= nil)
assert(a.getNext() ~= nil)
assert(a.getNext().getData() ~= nil)
assert(a.getNext().getNext() == nil)

-- can set the data
b = a.getNext()
data = { stuff = "wat" }
b.setData(data)
assert(b.getData() == data)

-- can set the link to another node
b.setNext(a)
assert(b.getNext() == a)

-- doing so creates a loop
p = a

count = 0
while (p ~= nil and count < 4) do
    p = p.getNext()
    count = count + 1
end

assert(count == 4)

print("LINKED LIST DIAGNOSTICS")

l = LinkedList()
i = l.getIterator()

-- can create an empty linked list
assert(i ~= nil)
assert(not i.hasNext())
assert(i.getNext() == nil)

-- can append 3 elements to a linked list
l.append(0).append(1).append(2)
assert(l.getLength() == 3)

-- can iterate a linked list
i = l.getIterator()
count = 0

while(i.hasNext()) do
    local n = i.getNext()
    assert(n.getData() == count)
    count = count + 1
end

-- linkedlist#each iterates the list
i = l.getIterator()
count = 0
did_run = false

l.each(function (node, index)
    did_run = true
    count = count + 1
    assert(count == index)
    assert(node ~= nil)
    assert(i.getNext() == node)
end)

assert(did_run)

-- can push elements to the front of the list
l = LinkedList()
l.push(0).push(1).push(2)
assert(l.getLength() == 3)

-- elements appear in the list in reverse order
i = l.getIterator()
count = 2

while(i.hasNext()) do
    local n = i.getNext()
    assert(n.getData() == count)
    count = count - 1
end

-- can pop from a list
assert(l.pop() == 2)
assert(l.getLength() == 2)

-- can pop the last element from a list
l = LinkedList()
l.push(0)
assert(l.pop() == 0)

print("LINKED LISTS ALL PASS")

return LinkedList
