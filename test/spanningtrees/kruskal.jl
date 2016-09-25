using LightGraphs
using Base.Test

g = Graph(4)
add_edge!(g, 1,2)
add_edge!(g, 1,3)
add_edge!(g, 1,4)
add_edge!(g, 2,1)
add_edge!(g, 2,3)
add_edge!(g, 2,4)
add_edge!(g, 3,1)
add_edge!(g, 3,2)
add_edge!(g, 3,4)
add_edge!(g, 4,1)
add_edge!(g, 4,2)
add_edge!(g, 4,3)

# Creating custom adjacency matrix
distmx = zeros(4,4)

# Populating custom adjacency matrix
distmx[1,2] = 1
distmx[1,3] = 5
distmx[1,4] = 6
distmx[2,1] = 1
distmx[2,3] = 4
distmx[2,4] = 10
distmx[3,1] = 5
distmx[3,2] = 4
distmx[3,4] = 3
distmx[4,1] = 6
distmx[4,2] = 10
distmx[4,3] = 3

# Testing Kruskal's algorithm
mst = kruskal_mst(g, distmx)
vec_mst = Vector{LightGraphs.KruskalHeapEntry{Float64}}()
push!(vec_mst, LightGraphs.KruskalHeapEntry(LightGraphs.Edge(1, 2), 1.0))
push!(vec_mst, LightGraphs.KruskalHeapEntry(LightGraphs.Edge(3, 4), 3.0))
push!(vec_mst, LightGraphs.KruskalHeapEntry(LightGraphs.Edge(2, 3), 4.0))

@test mst == vec_mst
