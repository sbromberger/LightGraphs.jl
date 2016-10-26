using LightGraphs
using Base.Test

g = CompleteGraph(4)

distmx = [
  0  1  5  6
  1  0  4  10
  5  4  0  3
  6  10  3  0
]

# Testing Prim's algorithm
mst = prim_mst(g, distmx)
vec_mst = Vector{Edge}([Edge(1, 2), Edge(2, 3), Edge(3, 4)])

@test mst == vec_mst

#second test
g = Graph(8)
add_edge!(g, 2,8)
add_edge!(g, 1,3)
add_edge!(g, 6,8)
add_edge!(g, 1,8)
add_edge!(g, 3,4)
add_edge!(g, 2,4)
add_edge!(g, 2,6)
add_edge!(g, 3,8)
add_edge!(g, 6,5)
add_edge!(g, 2,3)
add_edge!(g, 5,7)
add_edge!(g, 1,7)
add_edge!(g, 4,7)
add_edge!(g, 7,3)
add_edge!(g, 1,5)
add_edge!(g, 5,8)

distmx_sec = zeros(8, 8)
distmx_sec[2,8] = distmx_sec[8,2] = 0.19
distmx_sec[1,3] = distmx_sec[3,1] = 0.26
distmx_sec[6,8] = distmx_sec[8,6] = 0.28
distmx_sec[1,8] = distmx_sec[8,1] = 0.16
distmx_sec[3,4] = distmx_sec[4,3] = 0.17
distmx_sec[2,4] = distmx_sec[4,2] = 0.29
distmx_sec[2,6] = distmx_sec[6,2] = 0.32
distmx_sec[3,8] = distmx_sec[8,3] = 0.34
distmx_sec[5,6] = distmx_sec[6,5] = 0.35
distmx_sec[2,3] = distmx_sec[3,2] = 0.36
distmx_sec[5,7] = distmx_sec[7,5] = 0.93
distmx_sec[1,7] = distmx_sec[7,1] = 0.58
distmx_sec[4,7] = distmx_sec[7,4] = 0.52
distmx_sec[3,7] = distmx_sec[7,3] = 0.40
distmx_sec[1,5] = distmx_sec[5,1] = 0.38
distmx_sec[5,8] = distmx_sec[8,5] = 0.37

mst2 = prim_mst(g, distmx_sec)
vec2 = Vector{Edge}([Edge(1, 8),Edge(8, 2),Edge(1, 3),Edge(3, 4),Edge(8, 6),Edge(6, 5),Edge(3, 7)])

@test mst2 == vec2
