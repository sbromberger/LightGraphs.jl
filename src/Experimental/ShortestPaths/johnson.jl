using LightGraphs.Experimental.ShortestPaths
struct Johnson <: ShortestPathAlgorithm end
struct JohnsonResults{T<:Real, U<:Integer} <: ShortestPathResults
    parents::Matrix{U}
    dists::Matrix{T}
end
"""
    johnson_shortest_paths(g, distmx=weights(g))

Use the [Johnson algorithm](https://en.wikipedia.org/wiki/Johnson%27s_algorithm)
to compute the shortest paths between all pairs of vertices in graph `g` using an
optional distance matrix `distmx`.

Return a [`LightGraphs.JohnsonState`](@ref) with relevant
traversal information.

### Performance
Complexity: O(|V|*|E|)
"""
function shortest_paths(g::AbstractGraph{U},
    distmx::AbstractMatrix{T}, ::Johnson) where T <: Real where U <: Integer

    nvg = nv(g)
    type_distmx = typeof(distmx)
    #Change when parallel implementation of Bellman Ford available
    wt_transform = LightGraphs.Experimental.ShortestPaths.dists(shortest_paths(g, vertices(g), distmx, BellmanFord()))
    
    if !type_distmx.mutable && type_distmx !=  LightGraphs.DefaultDistance
        distmx = sparse(distmx) #Change reference, not value
    end

    #Weight transform not needed if all weights are positive.
    if type_distmx !=  LightGraphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)] 
        end
    end


    dists = Matrix{T}(undef, nvg, nvg)
    parents = Matrix{U}(undef, nvg, nvg)
    for v in vertices(g)
        dijk_state = dijkstra_shortest_paths(g, v, distmx)
        dists[v, :] = dijk_state.dists
        parents[v, :] = dijk_state.parents
    end

    broadcast!(-, dists, dists, wt_transform)
    for v in vertices(g)
        dists[:, v] .+= wt_transform[v] #Vertical traversal prefered
    end

    if type_distmx.mutable
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[dst(e)] - wt_transform[src(e)]
        end
    end

    return JohnsonResults(parents, dists)
end

shortest_paths(g::AbstractGraph, alg::Johnson) = shortest_paths(g, weights(g), alg)

function paths(s::JohnsonResults{T,U}, v::Integer) where T <: Real where U <: Integer
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

paths(s::JohnsonResults) = [paths(s, v) for v in 1:size(s.parents, 1)]
paths(st::JohnsonResults, s::Integer, d::Integer) = paths(st, s)[d]
