struct DagTopoResult{T,U <: Integer}  <: ShortestPathResult
    dists::Vector{T}
    parents::Vector{U}
end

"""
    struct DagTopo <: SSSPAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use [Topo Sort + DP](https://en.wikipedia.org/wiki/Topological_sorting#Application_to_shortest_path_finding)
to compute shortest paths. 

### Implementation Notes
`DagTopo` supports the following shortest-path functionality:
- (required) directed acyclic graphs 
- negative and non-negative edge weights
- (optional) multiple sources
- all destinations

### Performance
Time and space complexity is of the order O(V+E).
"""
struct DagTopo <: SSSPAlgorithm end

function shortest_paths(g::AbstractGraph, srcs::Vector{U}, distmx::AbstractMatrix{T}, alg::DagTopo) where {T,U <: Integer}
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)

    for src in srcs
        dists[src] = zero(T)
    end

    topo_sorted = topological_sort(g)

    for u in topo_sorted
        d = dists[u]
        d == typemax(T) && continue

        for v in outneighbors(g, u)
            alt = d + distmx[u, v]
            alt >= dists[v] && continue

            dists[v] = alt
            parents[v] = u
        end
    end

    return DagTopoResult{T,U}(dists, parents)
end

shortest_paths(g::AbstractGraph, s::Integer, distmx::AbstractMatrix, alg::DagTopo) = shortest_paths(g, [s], distmx, alg)
