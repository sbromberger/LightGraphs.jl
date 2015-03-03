using LightGraphs
import LightGraphs: inducedsubgraph
using Base.Test

g = BullGraph()
n = 3
h, vmap = inducedsubgraph(g, [1:n])
@test nv(h) == n
@test ne(h) == 3

h, vmap = inducedsubgraph(g, [1,2,4])
@test nv(h) == n
@test ne(h) == 2

h, vmap = inducedsubgraph(g, [1,5])
@test nv(h) == 2
@test ne(h) == 0