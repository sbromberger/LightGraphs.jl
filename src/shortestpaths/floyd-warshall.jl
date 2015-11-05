# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.


type FloydWarshallState{T}<:AbstractPathState
    dists::Matrix{T}
    parents::Matrix{Int}
end

doc"""Uses the [Floyd-Warshall algorithm](http://en.wikipedia.org/wiki/Floyd–Warshall_algorithm)
to compute shortest paths between all pairs of vertices in graph `g`. Returns a
`FloydWarshallState` with relevant traversal information, each is a
vertex-indexed vector of vectors containing the metric for each vertex in the
graph.

Note that this algorithm may return a large amount of data (it will allocate
on the order of $\mathcal{O}(nv^2)$).
"""
function floyd_warshall_shortest_paths{T}(
    g::SimpleGraph,
    distmx::AbstractArray{T, 2} = DefaultDistance()
)

    n_v = nv(g)
    dists = fill(typemax(T), (n_v,n_v))
    parents = zeros(Int, (n_v,n_v))

    # fws = FloydWarshallState(Matrix{T}(), Matrix{Int}())
    for v in 1:n_v
        dists[v,v] = zero(T)
    end
    undirected = !is_directed(g)
    for e in edges(g)
        u = src(e)
        v = dst(e)

        d = distmx[u,v]

        dists[u,v] = min(d, dists[u,v])
        parents[u,v] = u
        if undirected
            dists[v,u] = min(d, dists[v,u])
            parents[v,u] = v
        end
    end
    for w in vertices(g), u in vertices(g), v in vertices(g)
        if dists[u,w] == typemax(T) || dists[w,v] == typemax(T)
            ans = typemax(T)
        else
            ans = dists[u,w] + dists[w,v]
        end
        if dists[u,v] > ans
            dists[u,v] = dists[u,w] + dists[w,v]
            parents[u,v] = parents[w,v]
        end
    end
    fws = FloydWarshallState(dists, parents)
    # for r in 1:size(parents,1)    # row by row
    #     push!(fws.parents, vec(parents[r,:]))
    # end
    # for r in 1:size(dists,1)
    #     push!(fws.dists, vec(dists[r,:]))
    # end

    return fws
end

function enumerate_paths(s::FloydWarshallState, v::Integer)
    pathinfo = s.parents[v,:]
    paths = Vector{Int}[]
    for i in 1:length(pathinfo)
        if i == v
            push!(paths, Vector{Int}())
        else
            path = Vector{Int}()
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

enumerate_paths(s::FloydWarshallState) = [enumerate_paths(s, v) for v in 1:size(s.parents,1)]
enumerate_paths(st::FloydWarshallState, s::Integer, d::Integer) = enumerate_paths(st, s)[d]
