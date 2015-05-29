# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.


type FloydWarshallState{T<:Real} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{Int}
end

# @doc doc"""
#     Returns a FloydWarshallState, which includes distances and parents.
#     Each is a (vertex-indexed) vector of vectors containing the metric
#     for each other vertex in the graph.
#
#     Note that it is possible to consume large amounts of memory as the
#     space required for the FloydWarshallState is O(n^2).
#     """ ->
function floyd_warshall_shortest_paths{T<:Real}(
    g::AbstractGraph;
    edge_dists::AbstractArray{T,2} = zeros(0,0)
)

    # has_distances in distance.jl
    use_dists = has_distances(edge_dists)

    n_v = nv(g)
    S = typeof(one(T) + one(T))
    dists = fill(typemax(S), n_v, n_v)
    parents = zeros(Int, n_v, n_v)

    for v in 1:n_v
        dists[v,v] = 0.0
    end
    undirected = !is_directed(g)
    for e in edges(g)
        u = src(e)
        v = dst(e)
        if use_dists
            d = edge_dists[u,v]
        else
            d = 1.0
        end
        dists[u,v] = min(d, dists[u,v])
        parents[u,v] = u
        if undirected
            dists[v,u] = min(d, dists[v,u])
            parents[v,u] = v
        end
    end
    for w in vertices(g), u in vertices(g), v in vertices(g)
        if dists[u,w] == typemax(S) || dists[w,v] == typemax(S)
            continue
        end
        d = dists[u,w] + dists[w,v]
        if dists[u,v] > d
            dists[u,v] = d
            parents[u,v] = parents[w,v]
        end
    end

    return FloydWarshallState{S}(dists, parents)
end

function enumerate_paths(s::FloydWarshallState, v::Int)
    pathinfo = slice(s.parents, v, :)
    paths = Vector{Int}[]
    for i in 1:length(pathinfo)
        if i == v
            push!(paths, Int[])
        else
            path = Int[]
            currpathindex = i
            while currpathindex != 0
                push!(path,currpathindex)
                currpathindex = pathinfo[currpathindex]
            end
            push!(paths, reverse(path))
        end
    end
    return paths
end

enumerate_paths(s::FloydWarshallState) = [enumerate_paths(s, v) for v in 1:size(s.parents, 1)]
enumerate_paths(st::FloydWarshallState, s::Int, d::Int) = enumerate_paths(st, s)[d]
