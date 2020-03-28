"""
    struct Stress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
        k::Int
        vs::T
    end

A struct representing an algorithm to calculate the [stress centrality](http://med.bioinf.mpi-inf.mpg.de/netanalyzer/help/2.7/#stressDist)
of a graph `g` across all vertices, a specified subset of vertices `vs`, and/or a random subset of `k` vertices.

The stress centrality of a vertex ``n`` is defined as the number of shortest paths passing through ``n``.

### Optional Arguments
- `k=0`: If `k>0`, randomly sample `k` vertices from `vs` if provided, or from `vertices(g)` if empty.
- `vs=[]`: if `vs` is nonempty, run betweenness centrality only from these vertices.

### References
- Barabási, A.L., Oltvai, Z.N.: Network biology: understanding the cell's functional organization. Nat Rev Genet 5 (2004) 101-113
- Shimbel, A.: Structural parameters of communication networks. Bull Math Biophys 15 (1953) 501-507.

# Examples
```jldoctest
julia> using LightGraphs

julia> centrality(star_graph(3), Stress())
3-element Array{Int64,1}:
 2
 0
 0

 julia> centrality(cycle_graph(4), Stress())
4-element Array{Int64,1}:
 2
 2
 2
 2
```
"""
struct Stress{T<:AbstractVector{<:Integer}} <: CentralityMeasure
    k::Int
    vs::T
end

Stress(;k=0, vs=Vector{Int}()) = Stress(k, vs)

function centrality(g::AbstractGraph, alg::Stress)
    n_v = nv(g)
    vs = isempty(alg.vs) ? vertices(g) : alg.vs
    if alg.k > 0
        select!(vs, alg.k)
    end

    isdir = is_directed(g)

    stress = zeros(Int, n_v)
    dstate = ShortestPaths.Dijkstra(all_paths=true, track_vertices=true)
    for s in vs
        if degree(g, s) > 0
            state = ShortestPaths.shortest_paths(g, s, dstate)
            _stress_accumulate_basic!(stress, state, g, s)
        end
    end
    return stress
end

function _stress_accumulate_basic!(stress::Vector{<:Integer},
    state::ShortestPaths.DijkstraResult,
    g::AbstractGraph,
    si::Integer)

    n_v = length(ShortestPaths.parents(state)) # this is the ttl number of vertices
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

