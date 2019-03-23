"""
    ear_decomposition(g, s)

Return an Ear decomposition of the graph by using s as source for DFS Tree.

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
and return ear_decomposition of connected components if graph is not
connected.

OUTPUT:
- A nested array(list) representing the cycles and chains of the ear
    decomposition of the graph.

### Performance
Time complexity of this algorithm is `O(N+M)`, where `N` is number of vertices
and `M` is number of edges.

# Examples
```jldoctest

julia> using LightGraphs

julia> elist = [(1,2),(2,3),(3,4),(4,1),(1,5), (1, 6), (6, 7), (7, 8), (1, 8)]

julia> for e in elist
    add_edge!(g, e[1], e[2])
end

# g is simple undirected connected graph
julia> ear_decomposition(g, 1)
2-element Array{Any,1}:
 [1, 4, 3, 2, 1]
 [1, 8, 7, 6, 1]

julia> newlist = [(1,2),(2,3),(2,4),(3,4),(4,1), (5, 6), (5, 7), (5, 8), (6, 7), (7, 8)]

julia> g = SimpleGraph(8)

julia>  for e in newlist
            add_edge!(g, e[1], e[2])
        end

# g is undirected dis-connected graph
julia> ear_decomposition(g, 5)
4-element Array{Array{Int64,1},1}:
 [5, 7, 6, 5]
 [5, 8, 7]
 [1, 4, 3, 2, 1]
 [2, 4]
```

### References
Schmidt, Jens M. (2013a), "A Simple Test on 2-Vertex- and 2-Edge-Connectivity",
Information Processing Letters, 113 (7): 241–244, arXiv:1209.0700, 
doi:10.1016/j.ipl.2013.01.016.
"""

function ear_decomposition end
@traitfn function ear_decomposition(g::AG::(!IsDirected), s::Integer) where {T, AG<:AbstractGraph{T}}

    # List to store the order in which dfs visits vertices.
    dfs_order = Vector{T}()

    # Boolean dict to mark vertices as visited or unvisited during
    # Dfs traversal in graph.
    seen = zeros(Bool, nv(g))

    # Boolean dict to mark vertices as visited or unvisited in
    # Dfs tree traversal.
    traversed = zeros(Bool, nv(g))

    # Dict to store parent vertex of all the visited vertices.
    parents = zeros(T, nv(g))

    # List to store visit_time of vertices in Dfs traversal.
    value = zeros(T, nv(g))

    # List to store all the chains and cycles of the input graph G.
    chains = Vector{Vector{T}}()

    # Construct depth-first search tree from source s.
    S = Vector{T}([s])

    nodes = Vector{T}()
    push!(nodes, s)
    for u in vertices(g)
        push!(nodes, u)
    end

    # Perform ear decomposition on each connected component of input graph.
    for v in nodes
        if !(seen[v])
            # Start the depth first search from first vertex
            # mark source vertex s as seen
            seen[v] = true

            # Initialize S and dfs_order for every new DFS_Tree
            S = Vector{T}([v])
            dfs_order = T[]
            parents[v] = v
            push!(dfs_order, v)

            while !isempty(S)
                v = S[end]
                u = 0
                for n in neighbors(g, v)
                    if !seen[n]
                        u = n
                        push!(dfs_order, u)
                        break
                    end
                end
                if u == 0
                    pop!(S)
                else
                    seen[u] = true
                    push!(S, u)
                    parents[u] = v
                end
            end

            for (i, u) in enumerate(dfs_order)
                value[u] = i
            end

            # Traverse all the non Tree edges(G-T (non-tree edges)), according to
            # DFS order to find cycles and chains by traversing in DFS tree.
            for u in dfs_order
                for neighbor in neighbors(g, u)
                    if (value[u] < value[neighbor] && u != parents[neighbor])

                        # Make the firt end of non-tree edge visited
                        traversed[u] = true
                        chain = [u]

                        # Traverse DFS Tree of G and print all the not visited nodes
                        # Appending all the nodes in chain
                        pointer = neighbor
                        while true
                            push!(chain, pointer)
                            if traversed[pointer]
                                break
                            end
                            traversed[pointer] = true
                            pointer = parents[pointer]
                        end
                        push!(chains, chain)
                    end
                end
            end
        end
    end
    return chains
end
