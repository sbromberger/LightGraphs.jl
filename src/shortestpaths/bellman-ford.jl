# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################

struct NegativeCycleError <: Exception end

# AbstractPathState is defined in core
"""
    BellmanFordState{T, U}

An `AbstractPathState` designed for Bellman-Ford shortest-paths calculations.
"""
struct BellmanFordState{T<:Number,U<:Integer} <: AbstractPathState
    parents::Vector{U}
    dists::Vector{T}
end

function bellman_ford_shortest_paths!(
    graph::AbstractGraph,
    sources::AbstractVector{T},
    distmx::AbstractMatrix{R},
    state::BellmanFordState
    ) where R<:Real where T<:Integer

    active = Set{T}()
    for v in sources
        state.dists[v] = 0
        state.parents[v] = 0
        push!(active, v)
    end
    no_changes = false
    for i in one(T):nv(graph)
        no_changes = true
        new_active = Set{T}()
        for u in active
            for v in out_neighbors(graph, u)
                edist = distmx[u, v]
                if state.dists[v] > state.dists[u] + edist
                    state.dists[v] = state.dists[u] + edist
                    state.parents[v] = u
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
    return state
end

"""
    bellman_ford_shortest_paths(g, s, distmx=weights(g))
    bellman_ford_shortest_paths(g, ss, distmx=weights(g))

Compute shortest paths between a source `s` (or list of sources `ss`) and all
other nodes in graph `g` using the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm).
Return a [`BellmanFordState`](@ref) with relevant traversal information.
"""
function bellman_ford_shortest_paths(
    graph::AbstractGraph,
    sources::AbstractVector{U},
    distmx::AbstractMatrix{T} = weights(graph)
    ) where T where U<:Integer
    nvg = nv(graph)
    state = BellmanFordState(zeros(U, nvg), fill(typemax(T), nvg))
    bellman_ford_shortest_paths!(graph, sources, distmx, state)
end

bellman_ford_shortest_paths(
    graph::AbstractGraph,
    v::Integer,
    distmx::AbstractMatrix = weights(graph)
    ) = bellman_ford_shortest_paths(graph, [v], distmx)

has_negative_edge_cycle(g::AbstractGraph) = false

function has_negative_edge_cycle(g::AbstractGraph, distmx::AbstractMatrix)
    try
        bellman_ford_shortest_paths(g, vertices(g), distmx)
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end

function enumerate_paths(state::AbstractPathState, vs::Vector{T}) where T<:Integer
    parents = state.parents

    num_vs = length(vs)
    all_paths = Vector{Vector{T}}(num_vs)
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
