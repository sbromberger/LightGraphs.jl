"""
    ear_decomposition(g)

Return an Ear decomposition of the graph.

An ear of an undirected unweighted connected graph `G` is a path `P` where
the two endpoints of the path may coincide (i.e., form a cycle), but where
otherwise no repetition of edges or vertices is allowed, so every internal
vertex of `P` has degree two in `P`.

An ear decomposition of an undirected graph `G` is a partition of its
set of edges into a sequence of ears, such that the one or two endpoints
of each ear belong to earlier ears in the sequence and such that the
internal vertices of each ear do not belong to any earlier ear.

For more information, see the 
[Ear Decomposition](https://en.wikipedia.org/wiki/Ear_decomposition)

It will throw an error if input graph is directed/disconnected graph. 

OUTPUT:
- A nested array(list) representing the cycles and chains of the ear
    decomposition of the graph.

### Performance
Time complexity of this algorithm is `O(N+M)`, where `N` is number of vertices
and `M` is number of edges.

### Examples
```jldoctest

julia> using LightGraphs

julia> elist = [(1,2),(2,3),(3,4),(4,1),(1,5), (1, 6), (6, 7), (7, 8), (1, 8)]

julia> g = SimpleGraph(8)

julia> for e in elist
    add_edge!(g, e[1], e[2])
end

julia> ear_decomposition(g)
2-element Array{Any,1}:
 [1, 4, 3, 2, 1]
 [1, 8, 7, 6, 1]
```

### References
Schmidt, Jens M. (2013a), "A Simple Test on 2-Vertex- and 2-Edge-Connectivity",
Information Processing Letters, 113 (7): 241–244, arXiv:1209.0700, 
doi:10.1016/j.ipl.2013.01.016.
"""

function ear_decomposition end
@traitfn function ear_decomposition(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}} !is_connected(g) && throw(ArgumentError("Graph must be connected"))

    # List to store the order in which dfs visits vertices.
    dfs_order = []

    # Boolean dict to mark vertices as visited or unvisited during
    # Dfs traversal in graph.
    seen = Set()

    # Boolean dict to mark vertices as visited or unvisited in
    # Dfs tree traversal.
    traversed = Set()

    # Dict to store parent vertex of all the visited vertices.
    parent = Dict()

    # List to store visit_time of vertices in Dfs traversal.
    value = Dict()

    # List to store all the chains and cycles of the input graph G.
    chains = []

    nodes = []
    for i in vertices(g) 
    	append!(nodes, i)
    end
    parent[nodes[1]] = -1

    # DFS() : Function that performs depth first search on input graph G and
    #         stores DFS tree in parent array format.
    function DFS(v)
        """
        Depth first search step from vertex v.
        """
        # make v are visited, update its time of visited and value
        push!(seen, v)
        append!(dfs_order, v)

        # Traverse though all the neighbor nodes of v
        for u in neighbors(g, v)
            # if any neighbor is not visited, enter
            if !(u in seen)
                # Set the parent of u in DFS tree as v and continue
                # exploration
                parent[u] = v
                DFS(u)
            end
        end
    end

    # Traverse() : Function that use G-T (non-tree edges) to find cycles
    #              and chains by traversing in DFS tree.
    function traverse(start, pointer)
        # Make the firt end of non-tree edge visited
        push!(traversed, start)
        chain = [start]

        # Traverse DFS Tree of G and print all the not visited nodes
        # Appending all the nodes in chain
        while true
            append!(chain, pointer)
            if pointer in traversed
                break
            end
            push!(traversed, pointer)
            pointer = parent[pointer]
        end
        push!(chains, chain)
    end

    # Perform ear decomposition on each connected component of input graph.
    for v in nodes
        if !(v in seen)
            # Start the depth first search from first vertex
            DFS(v)
            for (i, u) in enumerate(dfs_order)
                value[u] = i
            end

            # Traverse all the non Tree edges, according to DFS order
            for u in dfs_order
                for neighbor in neighbors(g, u)
                    if (value[u] < value[neighbor] && u != parent[neighbor])
                        traverse(u, neighbor)
                    end
                end
            end
            dfs_order = []
        end
    end
    return(chains)
end
