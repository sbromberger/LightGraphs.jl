# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################

using Base.Threads

export parallel_bellman_ford_shortest_paths_2, parallel_bellman_ford_shortest_paths, 
seq_bellman_ford_shortest_paths, parallel_bellman_ford_shortest_paths_3,
parallel_bellman_ford_shortest_paths_4, seq_bellman_ford_shortest_paths

struct NegativeCycleError <: Exception end

# AbstractPathState is defined in core
"""
    BellmanFordState{T, U}

An `AbstractPathState` designed for Bellman-Ford shortest-paths calculations.
"""
struct BellmanFordState{T<:Real, U<:Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
end

export seq_get_parents
function seq_get_parents(
    g::AbstractGraph{U}, 
    distmx::AbstractMatrix{T},
    dists::Array{T}
    ) where T <: Real where U <: Integer
#parents of sources/unreachable nodes will be 0. 
    parents = zeros(U, nv(g))

    for v in vertices(g)
        d = dists[v]
        d >= typemax(T) && continue
        for u in outneighbors(g, v)
            if d + distmx[v, u] <= dists[u] #This is the relaxed edge
                parents[u] = v
            end
        end
    end
    return parents
end


export seq_bellman_ford_shortest_paths_2
function seq_bellman_ford_shortest_paths_2(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}
    ) where T<:Real where U<:Integer

    active = Set{U}(sources)
    dists = fill(typemax(T), nv(graph))
    dists[sources] .= 0
    no_changes = false
    for i in one(U):nv(graph)
        no_changes = true
        new_active = Set{U}()
        for u in active
            for v in outneighbors(graph, u)
                relax_dist = distmx[u, v] + dists[u]
                if dists[v] > relax_dist
                    dists[v] = relax_dist
                    no_changes = false
                    push!(new_active, v)
                end
            end
        end
        if no_changes
            break
        end
        active = new_active
    end
    #no_changes || throw(NegativeCycleError())
    return BellmanFordState(seq_get_parents(graph, distmx, dists), dists)
end


"""
    seq_bellman_ford_shortest_paths(g, sources, distmx)

Sequential implementation of [`LightGraphs.bellman_ford_shortest_paths`](@ref).

"""
function seq_bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}
    ) where T<:Real where U<:Integer

    active = Set{U}(sources)
    dists = fill(typemax(T), nv(graph))
    parents = zeros(U, nv(graph))
    dists[sources] .= 0
    no_changes = false
    for i in one(U):nv(graph)
        no_changes = true
        new_active = Set{U}()
        for u in active
            for v in outneighbors(graph, u)
                relax_dist = distmx[u, v] + dists[u]
                if dists[v] > relax_dist
                    dists[v] = relax_dist
                    parents[v] = u
                    no_changes = false
                    push!(new_active, v)
                end
            end
        end
        if no_changes
            break
        end
        active = new_active
    end
    #no_changes || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end

#Helper function used due to performance bug in @threads.
function _loop_body!(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{T},
    parents::Vector{U},
    active::Vector{U},
    n_threads::Integer,
    dists_t::Vector{Vector{T}},
    parents_t::Vector{Vector{U}},
    active_t::Vector{Set{U}},
    ) where T<:Real where U<:Integer


    #Perform edge relaxations in parallel on the edges starting from active vertices.
    #but thread i only updates (dists_t[i], parents_t[i], active_t[i])

    @threads for v in active
        local_dists = dists_t[threadid()]
        local_parents = parents_t[threadid()]
        local_active = active_t[threadid()]        
        #Reminder: Changes made to local_dists reflect on dists_t[threadid()]

        #v_neighbors = outneighbors(g, v)
        d = dists[v]
        outneigh = outneighbors(g, v)
        for u in outneigh
            relax_dist = d + distmx[v, u]
            if relax_dist < dists[u] && relax_dist < local_dists[u]
                local_dists[u] = relax_dist
                local_parents[u] = v
                push!(local_active, u)
            end
        end
    end

    #Update dists, parents, active from dists_t, parents_t, active_t
    for i in 1:n_threads
        local_dists = dists_t[i]
        local_parents = parents_t[i]
        local_active = active_t[i] 
        for v in local_active
            if local_dists[v] < dists[v]
                dists[v] = local_dists[v]
                parents[v] = local_parents[v]
            end
        end
    end
end

"""
    parallel_floyd_warshall_shortest_paths(g, sources, distmx)

Parallel implementation of [`LightGraphs.bellman_ford_shortest_paths`](@ref).

### Performance
Memory: O(nthreads()*|V|).
Approximately nthreads()*|V|*(size(U)+size(T))
"""
function parallel_bellman_ford_shortest_paths(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= zero(T) 
    active = Vector{U}(undef, length(sources))
    active .= sources

    
    #Auxillary memory used for multi-threading.
    #Thread i will have access to (dists_t[i], parents_t[i], active_t[i])    
    n_threads = nthreads()
    dists_t = [dists[:] for i in 1:n_threads]
    parents_t = fill(zeros(U, nvg), n_threads)
    active_t = fill(Set{U}([]), n_threads)

    for i in one(U):nvg
        _loop_body!(g, distmx, dists, parents, active, n_threads, dists_t, parents_t, active_t)
        
        active = collect(reduce(union, Set{U}([]), active_t))#Cobine active_t into active
        isempty(active) && break
        for i in 1:n_threads
            empty!(active_t[i])
        end
    end

    #isempty(active) || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end

#=
function _loop_body!_2(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{T},
    parents::Vector{U},
    active::Set{U}
    ) where T<:Real where U<:Integer

    # first initialisation to active will also change to (allVertices-sources)

    prev_dists = deepcopy(dists) # find a function which does this if deepcopy doesn't exist
    
    tmp_active = collect(active)
    @threads for v in tmp_active
        prev_dist_vertex = prev_dists[v]
        for u in inneighbors(g, v)
                relax_dist = prev_dists[u] == typemax(T) ? typemax(T) : prev_dists[u] + distmx[u,v]
                if prev_dist_vertex > relax_dist
                    prev_dist_vertex = relax_dist
                    parents[v] = u
                end
        end
        dists[v] = prev_dist_vertex
    end

    empty!(active)
    for v in vertices(g)
        if dists[v] < prev_dists[v]
            union!(active, outneighbors(g, v))
        end
    end

    # compare prev_dists and dists to see if any vertex changed and push changed vertices into new active
    # you can just do with two lists to maintain prev_dists and dists
end

function parallel_bellman_ford_shortest_paths_2(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    nvg = nv(g)
    active = Set{U}()
    for s in sources
        union!(active, outneighbors(g, s))
    end
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= 0

    for i in one(U):nvg
        _loop_body!_2(g, distmx, dists, parents, active)

        isempty(active) && break
    end

    #isempty(active) || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end

function _loop_body!_3(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{T},
    parents::Vector{U},
    active::Vector{U},
    locks::Vector{Mutex}
    ) where T<:Real where U<:Integer


    #Perform edge relaxations in parallel on the edges starting from active vertices.
    #but thread i only updates (dists_t[i], parents_t[i], active_t[i])

    prev_dists = deepcopy(dists)
    active_vec = collect(active)
    empty!(active)

    @threads for v in collect(active_vec)
        d = prev_dists[v]
        for u in outneighbors(g, v)
            relax_dist = d + distmx[v, u]
            if relax_dist < prev_dists[u]
                lock(locks[u])
                if relax_dist < dists[u]
                    dists[u] = relax_dist
                    parents[u] = v
                    push!(active, u)
                end
                unlock(locks[u])
            end
        end
    end

    
end

function parallel_bellman_ford_shortest_paths_3(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= zero(T) 
    active = Vector{U}(undef, length(sources))
    active .= sources
    locks = [Mutex() for i in vertices(g)]    

    for i in one(U):nvg
        _loop_body!_3(g, distmx, dists, parents, active, locks)
        
        isempty(active) && break
    end

    #isempty(active) || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end
=#



function get_parallel_bellman_ford_parents(
    g::AbstractGraph{U}, 
    distmx::AbstractMatrix{T},
    dists::Array{T}
    ) where T <: Real where U <: Integer
 
    parents = [Atomic{U}(0) for i in 1: nv(g)]
    active = findall((x)-> x!=typemax(T), dists)

    @threads for v in active #To be multi-threaded
        d = dists[v]
        for u in outneighbors(g, v)
            if d + distmx[v, u] <= dists[u] #This is the relaxed edge
                atomic_cas!(parents[u], zero(U), v)
            end
        end
    end
    return [p[] for p in parents]
end

function _loop_body!_2(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{Atomic{T}},
    active::Vector{U},
    prev_dists::Vector{T}
    ) where T<:Real where U<:Integer

    for v in active #To be multi-threaded
        d = prev_dists[v]
        for u in outneighbors(g, v)
           atomic_min!(dists[u], d + distmx[v, u]) 
        end
    end

end

function parallel_bellman_ford_shortest_paths_2(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}=weights(g)
    ) where T<:Real where U<:Integer

    nvg = nv(g)

    dists = [Atomic{T}(typemax(T)) for i = 1:nvg]
    dists[sources] .= Atomic{T}(zero(T))

    active = Vector{U}(undef, length(sources)) #Make type U
    active .= sources
    sizehint!(active, nvg)

    prev_dists = Vector{T}(undef, nvg)
    for i in one(U):nvg
        prev_dists .= [d[] for d in dists]

        _loop_body!_2(g, distmx, dists, active, prev_dists)

        empty!(active)
        for v in vertices(g)
            if dists[v][] < prev_dists[v] 
                push!(active, v)
            end
        end

        isempty(active) && break
    end
    #isempty(active) || throw(NegativeCycleError())

    dists = [d[] for d in dists]
    parents = get_parallel_bellman_ford_parents(g, distmx, dists)
    return BellmanFordState(parents, dists)
end


"""
    bellman_ford_shortest_paths(g, s, distmx=weights(g); parallel=false)
    bellman_ford_shortest_paths(g, ss, distmx=weights(g); parallel=false)

Compute shortest paths between a source `s` (or list of sources `ss`) and all
other nodes in graph `g` using the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
Return a [`LightGraphs.BellmanFordState`](@ref) with relevant traversal information.

### Optional Arguments
- `allpaths=false`: If true, the algorithm runs in parallel.
"""
bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T} = weights(graph);
    parallel=false
    ) where T<:Real where U<:Integer = (parallel ? 
    parallel_bellman_ford_shortest_paths(graph, sources, distmx) : seq_bellman_ford_shortest_paths(graph, sources, distmx))

bellman_ford_shortest_paths(
    graph::AbstractGraph{U},
    v::Integer,
    distmx::AbstractMatrix{T} = weights(graph);
    parallel=false
    ) where T<:Real where U<:Integer = bellman_ford_shortest_paths(graph, [v], distmx, parallel=parallel)

has_negative_edge_cycle(g::AbstractGraph; parallel=false) = false

function has_negative_edge_cycle(
    g::AbstractGraph{U}, 
    distmx::AbstractMatrix{T}; 
    parallel=false
    ) where T<:Real where U<:Integer
    try
        bellman_ford_shortest_paths(g, vertices(g), distmx, parallel=parallel)
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end

function enumerate_paths(state::AbstractPathState, vs::Vector{T}) where T<:Integer
    parents = state.parents

    num_vs = length(vs)
    all_paths = Vector{Vector{T}}(undef, num_vs)
    for i = 1:num_vs
        all_paths[i] = Vector{T}()
        index = vs[i]
        if parents[index] != 0 || parents[index] == index
            while parents[index] != 0
                push!(all_paths[i], index)
                index = parents[index]
            end
            push!(all_paths[i], index)
            reverse!(all_paths[i])
        end
    end
    all_paths
end

enumerate_paths(state::AbstractPathState, v) = enumerate_paths(state, [v])[1]
enumerate_paths(state::AbstractPathState) = enumerate_paths(state, [1:length(state.parents);])

"""
    enumerate_paths(state[, vs])
Given a path state `state` of type `AbstractPathState`, return a
vector (indexed by vertex) of the paths between the source vertex used to
compute the path state and a single destination vertex, a list of destination
vertices, or the entire graph. For multiple destination vertices, each
path is represented by a vector of vertices on the path between the source and
the destination. Nonexistent paths will be indicated by an empty vector. For
single destinations, the path is represented by a single vector of vertices,
and will be length 0 if the path does not exist.

### Implementation Notes
For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.
"""
enumerate_paths
