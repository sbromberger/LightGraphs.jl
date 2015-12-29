using LightGraphs
import LightGraphs: kruskal_minimum_spanning_tree
using Base.Test

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
mst = kruskal_minimum_spanning_tree(distmx,4)

# Generating theoretical result
resGraph = Graph(4)
add_edge!(resGraph,1,2)
add_edge!(resGraph,3,4)
add_edge!(resGraph,2,3)

#Comparing theoretical and resultant graphs
@test mst == resGraph
