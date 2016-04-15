using LightGraphs
import LightGraphs: induced_subgraph
using Base.Test

g = smallgraph(:bull)
n = 3
h = g[1:n]
@test nv(h) == n
@test ne(h) == 3

h = g[[1,2,4]]
@test nv(h) == n
@test ne(h) == 2

h = g[[1,5]]
@test nv(h) == 2
@test ne(h) == 0
@test typeof(h) == typeof(g)

g = DiGraph(100,200)
h = g[5:26]
@test nv(h) == 22
@test typeof(h) == typeof(g)

@test_throws ErrorException g[[1,1]]
