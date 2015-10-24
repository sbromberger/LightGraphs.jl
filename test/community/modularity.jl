n = 10
m = n*(n-1)/2
c = ones(Int, n)
g = CompleteGraph(n)
@test  abs(modularity(g, c) - 0) < 1e-10 
#
g = Graph(n)
@test modularity(g, c) == 0
