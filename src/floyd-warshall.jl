type FloydWarshallState
    dists::Vector{Vector{Float64}}
    parents::Vector{Vector{Int}}
end

# @doc doc"""
#     Returns a FloydWarshallState, which includes distances and parents.
#     Each is a (vertex-indexed) vector of vectors containing the metric
#     for each other vertex in the graph.
#
#     Note that it is possible to consume large amounts of memory as the
#     space required for the FloydWarshallState is O(n^2).
#     """ ->
function floyd_warshall(
    g::AbstractGraph;
    edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))
)

    use_dists = issparse(edge_dists)? nnz(edge_dists > 0) : !isempty(edge_dists)
    n_v = nv(g)
    dists = fill(convert(Float64,Inf), (n_v,n_v))
    parents = zeros(Int, (n_v,n_v))

    fws = FloydWarshallState(Vector{Float64}[], Vector{Int}[])
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
        if dists[u,v] > dists[u,w] + dists[w,v]
            dists[u,v] = dists[u,w] + dists[w,v]
            parents[u,v] = parents[w,v]
        end
    end
    for r in 1:size(parents,1)    # row by row
        push!(fws.parents, vec(parents[r,:]))
    end
    for r in 1:size(dists,1)
        push!(fws.dists, vec(dists[r,:]))
    end

    return fws
end
