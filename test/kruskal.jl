using LightGraphs
import LightGraphs: kruskal_minimum_spanning_tree
using Base.Test

"""is_symetric: test if a matrix is symmetric in n^2 time."""
function is_symetric(distmx)
	# Checking if the entered weight matrix is symmetric
	n = size(distmx, 1)
	for i in 1:n
		for j in 1:n
			if(distmx[i,j] != distmx[j,i])
				return false
			end
		end
	end
	return true
end
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

@test is_symetric(distmx) == true


g = Graph(4)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
add_edge!(g, 1, 4)
add_edge!(g, 2, 1)
add_edge!(g, 2, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 1)
add_edge!(g, 3, 2)
add_edge!(g, 3, 4)
add_edge!(g, 4, 1)
add_edge!(g, 4, 2)
add_edge!(g, 4, 3)

# Testing Kruskal's algorithm
mst = kruskal_minimum_spanning_tree(g, distmx)

# Generating theoretical result
resGraph = Graph(4)
add_edge!(resGraph,1,2)
add_edge!(resGraph,3,4)
add_edge!(resGraph,2,3)

#Comparing theoretical and resultant graphs
@test mst == resGraph

g = PathGraph(100)
@test kruskal_minimum_spanning_tree(g) == g
@test kruskal_minimum_spanning_tree(g) == g

function assert_spanning_tree(g::SimpleGraph, mst::SimpleGraph)
	@test ne(mst) == nv(g)-1
	@test all(degree(mst) .> 0)
	@test is_cyclic(mst) == false
end

nvwheel = 2000
g = WheelGraph(nvwheel)
mst = kruskal_minimum_spanning_tree(g)
mst = kruskal_minimum_spanning_tree(g)
assert_spanning_tree(g,mst)
dists = float(adjacency_matrix(g))
dists[:,1] /= 5.0
dists[1,:] /= 5.0
h = kruskal_minimum_spanning_tree(g, dists)
@test h == StarGraph(nvwheel)
g = WheelGraph(10)
dists = float(adjacency_matrix(g))
dists[:,1] *= 5.0
dists[1,:] *= 5.0
dists[1,2] = 0.1
dists[2,1] = 0.1
dists[10,2] = 2
dists[2,10] = 2
h = kruskal_minimum_spanning_tree(g, dists)
@test h == PathGraph(10)
