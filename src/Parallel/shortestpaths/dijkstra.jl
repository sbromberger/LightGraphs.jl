"""
    struct Parallel.MultipleDijkstraState{T, U}

An [`AbstractPathState`](@ref) designed for Parallel.dijkstra_shortest_paths calculation.
"""
struct MultipleDijkstraState{T<:Real,U<:Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

"""
    Parallel.dijkstra_shortest_paths(g, sources=vertices(g), distmx=weights(g))

Compute the shortest paths between all pairs of vertices in graph `g` by running
[`dijkstra_shortest_paths`] for every vertex and using an optional list of source vertex `sources` and
an optional distance matrix `distmx`. Return a [`Parallel.MultipleDijkstraState`](@ref) with relevant
traversal information.
"""
function dijkstra_shortest_paths(
    g::AbstractGraph{U},
    sources::AbstractVector = vertices(g),
    distmx::AbstractMatrix{T} = weights(g),
) where {T<:Real} where {U}

    n_v = nv(g)
    r_v = length(sources)

    # TODO: remove `Int` once julialang/#23029 / #23032 are resolved
    dists = SharedMatrix{T}(Int(r_v), Int(n_v))
    parents = SharedMatrix{U}(Int(r_v), Int(n_v))

    @sync @distributed for i = 1:r_v
        state = LightGraphs.dijkstra_shortest_paths(g, sources[i], distmx)
        dists[i, :] = state.dists
        parents[i, :] = state.parents
    end

    result = MultipleDijkstraState(sdata(dists), sdata(parents))
    return result
end
