# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

"""
    struct FloydWarshall <: ShortestPathAlgorithm

The structure used to configure and specify that [`shortest_paths`](@ref)
should use the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm).
No additional configuration parameters are specified or required.

`FloydWarshall` is the default all-pairs algorithm used when no source is specified.

### Implementation Notes
`FloydWarshall` supports the following shortest-path functionality:
- non-negative distance matrices / weights
- all-pairs shortest paths

### Performance
Space complexity is on the order of ``\\mathcal{O}(|V|^2)``.
"""
struct FloydWarshall <: ShortestPathAlgorithm end
struct FloydWarshallResult{T, U<:Integer} <: ShortestPathResult
    dists::Matrix{T}
    parents::Matrix{U}
end

function shortest_paths(g::AbstractGraph{U}, distmx::AbstractMatrix{T}, ::FloydWarshall) where {T, U<:Integer}
    nvg = nv(g)
    # if we do checkbounds here, we can use @inbounds later
    checkbounds(distmx, Base.OneTo(nvg), Base.OneTo(nvg))

    fwdists = fill(typemax(T), (Int(nvg), Int(nvg)))
    parents = zeros(U, (Int(nvg), Int(nvg)))

    @inbounds for v in vertices(g)
        fwdists[v, v] = zero(T)
    end
    undirected = !is_directed(g)
    @inbounds for e in edges(g)
        u = src(e)
        v = dst(e)

        d = distmx[u, v]

        fwdists[u, v] = min(d, fwdists[u, v])
        parents[u, v] = u
        if undirected
            fwdists[v, u] = min(d, fwdists[v, u])
            parents[v, u] = v
        end
    end

    @inbounds for pivot in vertices(g)
        # Relax fwdists[u, v] = min(fwdists[u, v], fwdists[u, pivot]+fwdists[pivot, v]) for all u, v
        for v in vertices(g)
            d = fwdists[pivot, v]
            d == typemax(T) && continue
            p = parents[pivot, v]
            for u in vertices(g)
                ans = (fwdists[u, pivot] == typemax(T) ? typemax(T) : fwdists[u, pivot] + d)
                if fwdists[u, v] > ans
                    fwdists[u, v] = ans
                    parents[u, v] = p
                end
            end
        end
    end
    fws = FloydWarshallResult(fwdists, parents)
    return fws
end

function paths(s::FloydWarshallResult{T, U}, v::Integer) where {T, U<:Integer}
    pathinfo = s.parents[v, :]
    fwpaths = Vector{Vector{U}}()
    for i in 1:length(pathinfo)
        if (i == v) || (s.dists[v, i] == typemax(T))
            push!(fwpaths, Vector{U}())
        else
            path = Vector{U}()
            currpathindex = U(i)
            while currpathindex != 0
                push!(path, currpathindex)
                if pathinfo[currpathindex] == currpathindex
                    currpathindex = zero(currpathindex)
                else
                    currpathindex = pathinfo[currpathindex]
                end
            end
            push!(fwpaths, reverse(path))
        end
    end
    return fwpaths
end

shortest_paths(g::AbstractGraph, alg::FloydWarshall) = shortest_paths(g, weights(g), alg)

# If we don't specify an algorithm AND there's no source, use Floyd-Warshall.
shortest_paths(g::AbstractGraph, distmx::AbstractMatrix=weights(g)) =
    shortest_paths(g, distmx, FloydWarshall())

paths(s::FloydWarshallResult) = [paths(s, v) for v in 1:size(s.parents, 1)]
paths(st::FloydWarshallResult, s::Integer, d::Integer) = paths(st, s)[d]
