"""
    ear_decomposition(g, s)

Return an Ear decomposition of the graph by using s as source for DFS Tree.

An ear of an undirected graph `G` is a path `P` in which no edges or vertices
are repeated except when endpoints are the same i.e forms a cycle.

Ear Decomposition: Partition the edge set of undirected graph `G` into a
sequence of paths or cycles(ears), such that only the end vertices of each path
are present in earlier paths.

For more information, see the 
[Ear Decomposition](https://en.wikipedia.org/wiki/Ear_decomposition)

It will throw an error if the input graph is a directed graph.

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
@traitfn function ear_decomposition(g::AG::(!IsDirected), s::Integer=1) where {T, AG<:AbstractGraph{T}}

    # Convert type of s to vertex of type `T`
    s = convert(typeof(T(0)), s)

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
    S = T[s]

    # Perform ear decomposition on each connected component of input graph.
    for v in Base.Iterators.flatten(((s,), vertices(g)))
        if !(seen[v])
            # Start the depth first search from first vertex
            # mark source vertex s as seen
            seen[v] = true

            # Initialize S and dfs_order for every new DFS_Tree
            S = T[v]
            dfs_order = T[]
            parents[v] = v
            push!(dfs_order, v)

            while !isempty(S)
                v = S[end]
                u = T(0)
                for neighbor in neighbors(g, v)
                    if !seen[neighbor]
                        u = neighbor
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

                        # Make the first end of non-tree edge visited
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
