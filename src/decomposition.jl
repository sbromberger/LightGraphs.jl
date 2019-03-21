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
@traitfn function ear_decomposition(g::AG::(!IsDirected), s::Integer) where {T, AG<:AbstractGraph{T}} !is_connected(g) && throw(ArgumentError("Graph must be connected"))

    # List to store the order in which dfs visits vertices.
    dfs_order = []

    # Boolean dict to mark vertices as visited or unvisited during
    # Dfs traversal in graph.
    seen = zeros(Bool, nv(g))

    # Boolean dict to mark vertices as visited or unvisited in
    # Dfs tree traversal.
    traversed = Set()

    # Dict to store parent vertex of all the visited vertices.
    parents = zeros(T, nv(g))

    # List to store visit_time of vertices in Dfs traversal.
    value = Dict()

    # List to store all the chains and cycles of the input graph G.
    chains = []

    # Construct depth-first search tree from source s.
    S = Vector{T}([s])

    # mark source vertex s as seen
    seen[s] = true

    parents[s] = s
    append!(dfs_order, s)

    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighbors(g, v)
            if !seen[n]
                u = n
                append!(dfs_order, u)
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
                push!(traversed, u)
                chain = [u]

                # Traverse DFS Tree of G and print all the not visited nodes
                # Appending all the nodes in chain
                pointer = neighbor
                while true
                    append!(chain, pointer)
                    if pointer in traversed
                        break
                    end
                    push!(traversed, pointer)
                    pointer = parents[pointer]
                end
                push!(chains, chain)
            end
        end
    end
    return chains
end
