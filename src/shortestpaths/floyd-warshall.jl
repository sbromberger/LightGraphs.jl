# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    struct FloydWarshallState{T, U}
An [`AbstractPathState`](@ref) designed for Floyd-Warshall shortest-paths calculations.
"""
struct FloydWarshallState{T,U<:Integer} <: AbstractPathState
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
Example :

julia> g= SimpleWeightedDiGraph(5);

julia> add_edge!(g,1,2,1); add_edge!(g,2,3,-2); add_edge!(g,3,4,-3); add_edge!(g,4,2,-4); add_edge!(g,3,5,5);

julia> a=floyd_warshall_shortest_paths(g);

julia> a.dists
5×5 Array{Float64,2}:
   0.0  -Inf  -Inf  -Inf  -Inf
 Inf    -Inf  -Inf  -Inf  -Inf
 Inf    -Inf  -Inf  -Inf  -Inf
 Inf    -Inf  -Inf  -Inf  -Inf
 Inf     Inf   Inf   Inf    0.0

julia> a.parents
5×5 Array{Int64,2}:
 0  4  2  3  3
 0  4  2  3  3
 0  4  2  3  3
 0  4  2  3  3
 0  0  0  0  0


"""
function floyd_warshall_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g)
) where T<:Real where U<:Integer
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

    has_negative_cycle=false

    #if dists[i][i]<0, it means there is a negative weight cycle.
    for i in vertices(g)
        if dists[i,i]<0
            has_negative_cycle=true
            break
        end
    end

    if has_negative_cycle
        #If dists[i,j] is negative, it means that there is a negative cycle in going from i to j
        @inbounds for i in vertices(g) , j in vertices(g) ,  t in vertices(g)
            if (dists[i,t] < typemax(T)) && (dists[t,t] < 0) && (dists[t,j] < typemax(T))
                dists[i,j] = - typemax(T)
            end
        end
    end

    fws = FloydWarshallState(dists, parents)
    return fws
end

function enumerate_paths(s::FloydWarshallState{T,U}, v::Integer) where T where U<:Integer
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
