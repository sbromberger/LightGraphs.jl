# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    struct FloydWarshallState{T, U}

An [`AbstractPathState`](@ref) designed for Floyd-Warshall shortest-paths calculations.
"""
struct FloydWarshallState{T, U <: Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

@doc """
    floyd_warshall_shortest_paths(g, distmx=weights(g))

Use the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm)
to compute the shortest paths between all pairs of vertices in graph `g` using an
optional distance matrix `distmx`. Return a [`LightGraphs.FloydWarshallState`](@ref) with relevant
traversal information.

### Performance
Space complexity is on the order of ``\\mathcal{O}(|V|^2)``.
"""
function floyd_warshall_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T} = weights(g),
) where {T <: Real} where {U <: Integer}
    nvg = nv(g)
    # if we do checkbounds here, we can use @inbounds later
    checkbounds(distmx, Base.OneTo(nvg), Base.OneTo(nvg))

    dists = fill(typemax(T), (Int(nvg), Int(nvg)))
    parents = zeros(U, (Int(nvg), Int(nvg)))

    @inbounds for v in vertices(g)
        dists[v, v] = zero(T)
    end
    undirected = !is_directed(g)
    @inbounds for e in edges(g)
        u = src(e)
        v = dst(e)

        d = distmx[u, v]

        dists[u, v] = min(d, dists[u, v])
        parents[u, v] = u
        if undirected
            dists[v, u] = min(d, dists[v, u])
            parents[v, u] = v
        end
    end

    @inbounds for pivot in vertices(g)
        # Relax dists[u, v] = min(dists[u, v], dists[u, pivot]+dists[pivot, v]) for all u, v
        for v in vertices(g)
            d = dists[pivot, v]
            d == typemax(T) && continue
            p = parents[pivot, v]
            for u in vertices(g)
                ans = (dists[u, pivot] == typemax(T) ? typemax(T) : dists[u, pivot] + d)
                if dists[u, v] > ans
                    dists[u, v] = ans
                    parents[u, v] = p
                end
            end
        end
    end
    fws = FloydWarshallState(dists, parents)
    return fws
end

function enumerate_paths(s::FloydWarshallState{T, U}, v::Integer) where {T} where {U <: Integer}
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
                if pathinfo[currpathindex] == currpathindex
                    currpathindex = zero(currpathindex)
                else
                    currpathindex = pathinfo[currpathindex]
                end
            end
            push!(paths, reverse(path))
        end
    end
    return paths
end

enumerate_paths(s::FloydWarshallState) = [enumerate_paths(s, v) for v in 1:size(s.parents, 1)]
enumerate_paths(st::FloydWarshallState, s::Integer, d::Integer) = enumerate_paths(st, s)[d]
