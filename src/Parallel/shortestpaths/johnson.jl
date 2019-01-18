function johnson_shortest_paths(g::AbstractGraph{U},
distmx::AbstractMatrix{T}=weights(g)) where T <: Real where U <: Integer

    nvg = nv(g)
    type_distmx = typeof(distmx)
#Change when parallel implementation of Bellman Ford available
    wt_transform = bellman_ford_shortest_paths(g, vertices(g), distmx).dists

    if !type_distmx.mutable && type_distmx !=  LightGraphs.DefaultDistance
        distmx = sparse(distmx) #Change reference, not value
    end

#Weight transform not needed if all weights are positive.
    if type_distmx !=  LightGraphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)] 
        end
    end


    dijk_state = Parallel.dijkstra_shortest_paths(g, vertices(g), distmx)
    dists = dijk_state.dists
    parents = dijk_state.parents


    broadcast!(-, dists, dists, wt_transform)
    for v in vertices(g)
        dists[:, v] .+= wt_transform[v] #Vertical traversal prefered
    end

    if type_distmx.mutable
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[dst(e)] - wt_transform[src(e)]
        end
    end

    return JohnsonState(dists, parents)
end

function enumerate_paths(s::JohnsonState{T,U}, v::Integer) where T <: Real where U <: Integer
    pathinfo = s.parents[v, :]
    paths = Vector{Vector{U}}()
    for i in 1:length(pathinfo)
        if (i == v) || (s.dists[v, i] == typemax(T))
            push!(paths, Vector{U}())
        else
            path = Vector{U}()
            currpathindex = i
            while currpathindex != 0
                push!(path, currpathindex)
                currpathindex = pathinfo[currpathindex]
            end
            push!(paths, reverse(path))
        end
    end
    return paths
end

enumerate_paths(s::JohnsonState) = [enumerate_paths(s, v) for v in 1:size(s.parents, 1)]
enumerate_paths(st::JohnsonState, s::Integer, d::Integer) = enumerate_paths(st, s)[d]

