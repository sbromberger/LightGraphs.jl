# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################

type NegativeCycleError <: Exception end

# AbstractPathState is defined in core
type BellmanFordState{T<:Number}<:AbstractPathState
    parents::Vector{Int}
    dists::Vector{T}
end

function bellman_ford_shortest_paths!{R<:Real}(
    graph::SimpleGraph,
    sources::AbstractVector{Int},
    distmx::AbstractArray{R, 2},
    state::BellmanFordState
)

    active = Set{Int}()
    for v in sources
        state.dists[v] = 0
        state.parents[v] = 0
        push!(active, v)
    end
    no_changes = false
    for i in 1:nv(graph)
        no_changes = true
        new_active = Set{Int}()
        for u in active
            for v in fadj(graph, u)
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

"""Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm)
to compute shortest paths between a source vertex `s` or a set of source
vertices `ss`. Returns a `BellmanFordState` with relevant traversal information
(see below).
"""
function bellman_ford_shortest_paths{T}(
    graph::SimpleGraph,

    sources::AbstractVector{Int},
    distmx::AbstractArray{T, 2} = DefaultDistance()
    )
    nvg = nv(graph)
    state = BellmanFordState(zeros(Int,nvg), fill(typemax(T), nvg))
    bellman_ford_shortest_paths!(graph, sources, distmx, state)
end

bellman_ford_shortest_paths{T}(
    graph::SimpleGraph,
    v::Int,
    distmx::AbstractArray{T, 2} = DefaultDistance()
) = bellman_ford_shortest_paths(graph, [v], distmx)

function has_negative_edge_cycle(graph::SimpleGraph)
    try
        bellman_ford_shortest_paths(graph, vertices(graph))
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end

function enumerate_paths(state::AbstractPathState, dest::Vector{Int})
    parents = state.parents

    num_dest = length(dest)
    all_paths = Array(Vector{Int},num_dest)
    for i=1:num_dest
        all_paths[i] = Vector{Int}()
        index = dest[i]
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

enumerate_paths(state::AbstractPathState, dest) = enumerate_paths(state, [dest])[1]
enumerate_paths(state::AbstractPathState) = enumerate_paths(state, [1:length(state.parents);])

"""Given a path state `state` of type `AbstractPathState` (see below), returns a
vector (indexed by vertex) of the paths between the source vertex used to
compute the path state and a destination vertex `v`, a set of destination
vertices `vs`, or the entire graph. For multiple destination vertices, each
path is represented by a vector of vertices on the path between the source and
the destination. Nonexistent paths will be indicated by an empty vector. For
single destinations, the path is represented by a single vector of vertices,
and will be length 0 if the path does not exist.

For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.
"""
enumerate_paths
