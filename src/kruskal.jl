####################################################
## Minimum Spanning Tree - Kruskal algorithm
####################################################

"""

Computes the minimum spanning tree of an undirected graph by using Kruskal's algorithm.

Requires arguments:
distmx::LightGraphs.Graph          # Adjacency matrix of the input graph
n::Int                             # The number of vertices in the graph 

Returns: An undirected graph which is the MST of the adjacency matrix.

"""


function kruskal_minimum_spanning_tree(distmx, n) 

	edgeList = []
	edgeCount = 0

	mst = Graph(n)

	for i in 1:n
		for j in i+1:n
			push!(edgeList,(distmx[i,j],i,j))	
		end
	end

	sort!(edgeList)
	
	for i in 1:length(edgeList)
		
		add_edge!(mst,edgeList[i][2],edgeList[i][3])
		edgeCount=edgeCount + 1
           
           if is_cyclic(mst)
               rem_edge!(mst,edgeList[i][2],edgeList[i][3])
               edgeCount = edgeCount - 1
           end
           
           if edgeCount == (n-1)
               break
           end
    end

    return mst

end


