"""
    struct Johnson <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Johnson algorithm](https://en.wikipedia.org/wiki/Johnson%27s_algorithm).

### Optional Fields
`maxdist<:Real` (default: `Inf`) option is the same as in [`Dijkstra`](@ref).

### Implementation Notes
`Johnson` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- all-pairs shortest paths

### Performance
Complexity: O(|V|*|E|)
"""
struct Johnson{T<:Real} <: ShortestPathAlgorithm
    maxdist::T
end

Johnson(; maxdist=typemax(Float64)) = Johnson(maxdist)

struct JohnsonResult{T, U<:Integer} <: ShortestPathResult
    parents::Matrix{U}
    dists::Matrix{T}
end

function shortest_paths(g::AbstractGraph{U}, distmx::AbstractMatrix{T}, alg::Johnson) where {T, U<:Integer}
    nvg = nv(g)
    type_distmx = typeof(distmx)
    #Change when parallel implementation of Bellman Ford available
    wt_transform = distances(shortest_paths(g, vertices(g), distmx, BellmanFord()))
    
    if !type_distmx.mutable && type_distmx !=  LightGraphs.DefaultDistance
        distmx = sparse(distmx) #Change reference, not value
    end

    #Weight transform not needed if all weights are positive.
    if type_distmx !=  LightGraphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)]
        end
    end


    jdists = Matrix{T}(undef, nvg, nvg)
    jparents = Matrix{U}(undef, nvg, nvg)
    for v in vertices(g)
        dijk_state = shortest_paths(g, v, distmx, Dijkstra(maxdist=alg.maxdist))
        jdists[v, :] = distances(dijk_state)
        jparents[v, :] = parents(dijk_state)
    end

    broadcast!(-, jdists, jdists, wt_transform)
    for v in vertices(g)
        jdists[:, v] .+= wt_transform[v] #Vertical traversal prefered
    end

    if type_distmx.mutable
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[dst(e)] - wt_transform[src(e)]
        end
    end

    return JohnsonResult(jparents, jdists)
end

shortest_paths(g::AbstractGraph, alg::Johnson) = shortest_paths(g, weights(g), alg)

function paths(s::JohnsonResult{T, U}, v::Integer) where {T, U <: Integer}
    pathinfo = s.parents[v, :]
    paths = Vector{Vector{U}}()
    for i in 1:length(pathinfo)
        if (i == v) || (s.dists[v, i] == typemax(T))
            push!(paths, Vector{U}())
        else
            path = Vector{U}()
            currpathindex = U(i)
            while currpathindex != 0
                push!(path, currpathindex)
                currpathindex = pathinfo[currpathindex]
            end
            push!(paths, reverse(path))
        end
    end
    return paths
end

paths(s::JohnsonResult) = [paths(s, v) for v in 1:size(s.parents, 1)]
paths(st::JohnsonResult, s::Integer, d::Integer) = paths(st, s)[d]
