"""
    stress_centrality(g[, vs])
    stress_centrality(g, k)

Calculate the [stress centrality](http://med.bioinf.mpi-inf.mpg.de/netanalyzer/help/2.7/#stressDist)
of a graph `g` across all vertices, a specified subset of vertices `vs`, or a random subset of `k`
vertices. Return a vector representing the centrality calculated for each node in `g`.

The stress centrality of a vertex ``n`` is defined as the number of shortest paths passing through ``n``.

### References
- Barabási, A.L., Oltvai, Z.N.: Network biology: understanding the cell's functional organization. Nat Rev Genet 5 (2004) 101-113
- Shimbel, A.: Structural parameters of communication networks. Bull Math Biophys 15 (1953) 501-507.

# Examples
```jldoctest
julia> using LightGraphs

julia> stress_centrality(star_graph(3))
3-element Array{Int64,1}:
 2
 0
 0

julia> stress_centrality(cycle_graph(4))
4-element Array{Int64,1}:
 2
 2
 2
 2
```
"""
function stress_centrality(g::AbstractGraph, vs::AbstractVector=vertices(g))
    n_v = nv(g)
    k = length(vs)
    isdir = is_directed(g)

    stress = zeros(Int, n_v)
    for s in vs
        if degree(g, s) > 0
            state = dijkstra_shortest_paths(g, s; allpaths=true, trackvertices=true)
            _stress_accumulate_basic!(stress, state, g, s)
        end
    end
    return stress
end

stress_centrality(g::AbstractGraph, k::Integer) =
    stress_centrality(g, sample(vertices(g), k))

function _stress_accumulate_basic!(stress::Vector{<:Integer},
    state::DijkstraState,
    g::AbstractGraph,
    si::Integer)

    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(Int, n_v)
    P = state.predecessors

    laststress = copy(stress)
    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source vertices by decreasing distance for this to work.
    S = reverse(state.closest_vertices) #Replaced sortperm with this
    for w in S  # w is the farthest vertex from si
        for v in P[w]  # get the predecessors of w
            if v > 0
                δ[v] +=  δ[w] + 1 # increment sp of pred
            end
        end
        δ[w] *= length(P[w]) # adjust the # of sps of vertex
        if w != si
            stress[w] += δ[w]
        end
    end
    return nothing
end
