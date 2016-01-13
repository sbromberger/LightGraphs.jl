"""

Computes the minimum spanning tree of an undirected graph by using Kruskal's algorithm.

Requires arguments:
distmx          				   # Weight matrix of the input graph 

Returns: An undirected graph which is the MST of the input.

"""


function kruskal_minimum_spanning_tree{T<:Real}(distmx::Matrix{T}) 

	edgeList = []
	edgeCount = 0

	(m,n) = size(distmx)

	# Checking whether input is a square matrix
	if(m != n)
		error("Not a square matrix")
	end

	# Checking if the entered weight matrix is symmetric
	for i in 1:n
		for j in 1:n
			if(distmx[i,j] != distmx[j,i])
				error("Not a symmetric matrix")
			end
		end
	end

	# Creating an empty undirected graph with n nodes
	mst = Graph(n)

	# Creating a list of all edges
	for i in 1:n
		for j in i+1:n
			push!(edgeList,(distmx[i,j],i,j))	
		end
	end

	# Sorting the list of all edges
	sort!(edgeList)
	
	# Creating the minimum spanning tree 
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

# Alternate method for default distances
kruskal_minimum_spanning_tree(g::Graph) =  kruskal_minimum_spanning_tree(full(adjacency_matrix(g)))
