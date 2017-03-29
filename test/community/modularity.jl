n = 10
m = n*(n-1)/2
c = ones(Int, n)
g = CompleteGraph(n)
@test  modularity(g, c) == 0
#
g = Graph(n)
@test modularity(g, c) == 0
