# this is a new shortest-paths algorithm. It replaces `dfs_parents` from LG 1.x.
# we have removed the ability to use custom neighbor functions, though.

"""
    struct DFS <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Depth-First Search algorithm](https://en.m.wikipedia.org/wiki/Depth-first_search).
No additional configuration parameters are specified or required.

### Implementation Notes
`DFS` supports the following shortest-path functionality:
- (optional) multiple sources
- all destinations

This implementation of DFS is iterative, not recursive.
"""
struct DFS <: ShortestPathAlgorithm end
struct DFSResult{U<:Integer} <: ShortestPathResult
    parents::Vector{U}
    dists::Vector{U}
end

function shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{U}, alg::DFS) where U<:Integer
    nvg = nv(g)
    parents = zeros(U, nvg)
    dists = fill(typemax(U), nvg)
    seen = falses(nvg)
    S = collect(ss)
    for s in ss
        dists[s] = 0
        seen[s] = true
    end
    while !isempty(S)
        v = S[end]
        u = 0
        for n in neighbors(g, v)
            if !seen[n]
                u = n
                break
            end
        end
        if u == 0
            pop!(S)
        else
            seen[u] = true
            push!(S, u)
            parents[u] = v
            dists[u] = dists[v] + 1
        end
    end
    return DFSResult(parents, dists)
end

shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{<:Integer}, alg::DFS) where {U<:Integer} = shortest_paths(g, U.(ss), alg)
shortest_paths(g::AbstractGraph{U}, s::Integer, alg::DFS) where {U<:Integer} = shortest_paths(g, Vector{U}([s]), alg)
