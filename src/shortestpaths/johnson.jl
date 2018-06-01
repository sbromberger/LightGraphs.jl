
"""
    struct JohnsonState{T, U}
An [`AbstractPathState`](@ref) designed for Johnson shortest-paths calculations.
"""
struct JohnsonState{T <: Real,U <: Integer} <: AbstractPathState
    dists::Matrix{T}
    parents::Matrix{U}
end

@doc """
    johnson_shortest_paths(g, distmx=weights(g); parallel=false)

### Implementation Notes
Use the [Johnson algorithm](https://en.wikipedia.org/wiki/Johnson%27s_algorithm)
to compute the shortest paths between all pairs of vertices in graph `g` using an
optional distance matrix `distmx`.
If the parameter parallel is set true, dijkstra_shortest_paths will run in parallel.
Parallel bellman_ford_shortest_paths is currently unavailable
Return a [`LightGraphs.JohnsonState`](@ref) with relevant
traversal information.
Behaviour in case of negative cycle depends on bellman_ford_shortest_paths.
Throws NegativeCycleError() if a negative cycle is present.
### Performance
Complexity: O(|V|*|E|)
If distmx is not mutable or of type, DefaultDistance than a sparse matrix will be produced using distmx.
In the case that distmx is immutable, to reduce memory overhead,  
if edge (a, b) does not exist in g then distmx[a, b] should be set to 0.
### Dependencies from LightGraphs
bellman_ford_shortest_paths
parallel_multisource_dijkstra_shortest_paths
dijkstra_shortest_paths
"""
function johnson_shortest_paths(g::AbstractGraph{U},
    distmx::AbstractMatrix{T}=weights(g);
    parallel::Bool=false
) where T <: Real where U <: Integer

    nvg = nv(g)
    type_distmx = typeof(distmx)
    #Change when parallel implementation of Bellman Ford available
    wt_transform = bellman_ford_shortest_paths(g, vertices(g), distmx).dists
    
    if !type_distmx.mutable && type_distmx !=  LightGraphs.DefaultDistance
        distmx = SparseArrays.sparse(distmx) #Change reference, not value
    end

    #Weight transform not needed if all weights are positive.
    if type_distmx !=  LightGraphs.DefaultDistance
        for e in edges(g)
            distmx[src(e), dst(e)] += wt_transform[src(e)] - wt_transform[dst(e)] 
        end
    end

    if !parallel
        dists = Matrix{T}(undef, nvg, nvg)
        parents = Matrix{U}(undef, nvg, nvg)
        for v in vertices(g)
            dijk_state = dijkstra_shortest_paths(g, v, distmx)
            dists[v, :] = dijk_state.dists
            parents[v, :] = dijk_state.parents
        end
    else
        dijk_state = parallel_multisource_dijkstra_shortest_paths(g, vertices(g), distmx)
        dists = dijk_state.dists
        parents = dijk_state.parents
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
