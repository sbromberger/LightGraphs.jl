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

function bellman_ford_shortest_paths!(
    graph::AbstractGraph,
    sources::AbstractVector{Int},
    distmx::AbstractArray{Float64, 2},
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
    if !no_changes
        throw(NegativeCycleError())
    end
    state
end


function bellman_ford_shortest_paths{T}(
    graph::AbstractGraph,

    sources::AbstractVector{Int},
    distmx::AbstractArray{T, 2} = DefaultDistance()
    )
    nvg = nv(graph)
    state = BellmanFordState(zeros(Int,nvg), fill(typemax(T), nvg))
    bellman_ford_shortest_paths!(graph, sources, distmx, state)
end

bellman_ford_shortest_paths{T}(
    graph::AbstractGraph,
    v::Int,
    distmx::AbstractArray{T, 2} = DefaultDistance()
) = bellman_ford_shortest_paths(graph, [v], distmx)

function has_negative_edge_cycle(graph::AbstractGraph)
    try
        bellman_ford_shortest_paths(graph, vertices(graph))
    catch e
        if isa(e, NegativeCycleError)
            return true
        end
    end
    return false
end


function enumerate_paths(state::AbstractPathState, dest::Vector{Int})
    parents = state.parents

    num_dest = length(dest)
    all_paths = Array(Vector{Int},num_dest)
    for i=1:num_dest
        all_paths[i] = Int[]
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
