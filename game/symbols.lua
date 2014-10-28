
local graph = Graph()

graph.insert("ONE")
graph.insert("TWO")
graph.insert("THREE")
graph.insert("FOUR")
graph.insert("FIVE")
graph.insert("SIX")

graph.connect(graph.sample(), graph.sample(), graph.sample())
graph.connect(graph.sample(), graph.sample(), graph.sample())
graph.connect(graph.sample(), graph.sample(), graph.sample())

love.debug.print(graph.toString())

return graph
