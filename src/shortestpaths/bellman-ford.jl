# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################
using Base.Threads

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
    sizehint!(active, nv(graph))
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
    no_changes || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end

#Helper function used due to performance bug in @threads.
function _loop_body!(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T},
    dists::Vector{T},
    parents::Vector{U},
    active::Set{U}
    ) where T<:Real where U<:Integer

    
    prev_dists = deepcopy(dists)
    
    tmp_active = collect(active)
    @threads for v in tmp_active
        prev_dist_vertex = prev_dists[v]
        for u in inneighbors(g, v)
                relax_dist = (prev_dists[u] == typemax(T) ? typemax(T) : prev_dists[u] + distmx[u,v])
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
end

"""
    parallel_bellman_ford_shortest_paths(g, sources, distmx)

Parallel implementation of [`LightGraphs.bellman_ford_shortest_paths`](@ref).
"""
function parallel_bellman_ford_shortest_paths(
    g::AbstractGraph{U},
    sources::AbstractVector{<:Integer},
    distmx::AbstractMatrix{T}
    ) where T<:Real where U<:Integer

    nvg = nv(g)
    active = Set{U}()
    sizehint!(active, nv(g))
    for s in sources
        union!(active, outneighbors(g, s))
    end
    dists = fill(typemax(T), nvg)
    parents = zeros(U, nvg)
    dists[sources] .= 0

    for i in one(U):nvg
        _loop_body!(g, distmx, dists, parents, active)

        isempty(active) && break
    end

    isempty(active) || throw(NegativeCycleError())
    return BellmanFordState(parents, dists)
end


"""
    bellman_ford_shortest_paths(g, s, distmx=weights(g))
    bellman_ford_shortest_paths(g, ss, distmx=weights(g))

Compute shortest paths between a source `s` (or list of sources `ss`) and all
other nodes in graph `g` using the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
Return a [`LightGraphs.BellmanFordState`](@ref) with relevant traversal information.

### Optional Arguments
- `parallel=false`: If true, the algorithm runs in parallel.
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
