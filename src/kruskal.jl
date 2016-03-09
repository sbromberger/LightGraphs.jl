# DataStructures needed for IntDisjointSets for Kruskal's algorithm.
import DataStructures: IntDisjointSets, in_same_set, union!
"""edgelist: construct a list (weight, src, dst) for all edges in a graph"""
function edgelist(g::SimpleGraph, distmx::AbstractMatrix)
	m, n = size(distmx)
	# Checking whether input is a square matrix
	if m != n
		error("Distances given is not a square matrix")
	end
	if m != nv(g)
		error("Distances are incompatible with graph g. nv=$nv, size(distmx)=$(size(distmx))")
	end
	edgeList = Vector{Tuple{Float64,Int,Int}}(0)
	for (i,j) in edges(g)
			push!(edgeList,(distmx[i,j],i,j))
	end
	return edgeList
end


"""

Computes the minimum spanning tree of an undirected graph by using Kruskal's algorithm.

Requires arguments:
g                                  # The graph
distmx          				   # Weight matrix of the input graph

Returns: An undirected graph which is the MST of the input.

"""
function kruskal_minimum_spanning_tree{T<:Real}(g::SimpleGraph, distmx::AbstractMatrix{T})
	# Creating a list of all edges
	T = eltype(distmx)
	edgeList = edgelist(g, distmx)
	# Sorting the list of all edges by weight lowest to highest
	sort!(edgeList)
	treevertices = zeros(Int, nv(g))
	mst = Vector{Tuple{T, Int,Int}}(nv(g)-1)
	totalweight, edgeCount = kruskal_minimum_spanning_tree!(g, edgeList, treevertices, mst)
	if edgeCount != nv(g)-1
		error("Resulting tree was not spanning nedges = $edgeCount")
	end
	return Graph(mst, nv(g))
end

function kruskal_minimum_spanning_tree(g)
	edgeList = [(1, src, dst) for (src,dst) in edges(g)]
	treevertices = zeros(Int, nv(g))
	mst = Vector{Tuple{Int, Int,Int}}(nv(g)-1)
	totalweight, edgeCount = kruskal_minimum_spanning_tree!(g, edgeList, treevertices, mst)
	if edgeCount != nv(g)-1
		error("Resulting tree was not spanning nedges = $edgeCount")
	end
	return Graph(mst, nv(g))
end

"""Creating the minimum spanning tree using Kruskal's algorithm
add edges in increasing weight, as long as they do not form a cycle uses
DataStructures.IntDisjointSets in order to efficiently maintain connected components of the tree.

g: input graph.
edgeList: vector of tuples (weight, src, dst) sorted by weight in increasing order.
treevertices: preallocated storage for vertices that end up in tree zeros(Int, 0).
mst: preallocated output representing the tree Vector of weight, src, dst, with length n-1.

treevertices[i] stores the degree of i in the MST
mst is returned with weights (which are redundant) to avoid the caller looking them up again.
We could use alternative formats in the future.

This implementation is intended to have reusable memory in case you need to use MST as an inner loop
kernel. Reset the treevertices and mst arrays to zeros using `fill!``.

Returns totalweight and edgeCount the MST is stored as an edgelist in the mst input array
edgeCount should always equal nv(g)-1
"""
function kruskal_minimum_spanning_tree!{T<:Real}(g::SimpleGraph,
										edgeList::Vector{Tuple{T, Int, Int}},
										treevertices::Vector{Int},
										mst::Vector{Tuple{T, Int, Int}})
	edgeCount = 0
	totalweight = 0
	n = nv(g)
	sets = IntDisjointSets(nv(g)) # creates a forest comprised of nv(g) singletons
	for i in 1:length(edgeList)
		weight, src, dst = edgeList[i]
		if treevertices[src] == 0 || treevertices[dst] == 0 || !in_same_set(sets, src, dst)
			mst[edgeCount+1] = (weight, src,dst)
			union!(sets, src, dst) # merges the sets that contain src and dst into one
			treevertices[src] += 1
			treevertices[dst] += 1
			edgeCount += 1
			totalweight += weight
		end

		# spanning trees have n-1 edges
		if edgeCount == n-1
		   break
	   end
	end

	return totalweight, edgeCount

end
