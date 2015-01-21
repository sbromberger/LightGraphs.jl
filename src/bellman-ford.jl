# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the states of Bellman Ford algorithm
#
###################################################################

type NegativeCycleError <: Exception end

type BellmanFordStates
    parents::Vector{Int}
    dists::Vector{Float64}
end

# create Bellman Ford states

function create_bellman_ford_states(g::AbstractFastGraph)
    n = nv(g)
    parents = Array(Int, n)
    dists = fill(typemax(Float64), n)

    BellmanFordStates(parents, dists)
end

function bellman_ford_shortest_paths!(
    graph::AbstractFastGraph,
    sources::AbstractVector{Int},
    state::BellmanFordStates)

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
            for e in out_edges(graph, u)
                v = dst(e)
                edist = dist(e)
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


function bellman_ford_shortest_paths(
    graph::AbstractFastGraph,
    sources::AbstractVector{Int})

    state = create_bellman_ford_states(graph)
    bellman_ford_shortest_paths!(graph, sources, state)
end

bellman_ford_shortest_paths(graph::AbstractFastGraph, v::Int) = bellman_ford_shortest_paths(graph, [v])

function has_negative_edge_cycle(graph::AbstractFastGraph)
    try
        bellman_ford_shortest_paths(graph, vertices(graph))
    catch e
        if isa(e, NegativeCycleError)
            return true
        end
    end
    return false
end


function enumerate_paths(state::BellmanFordStates, dest::Vector{Int})
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

enumerate_paths(state::BellmanFordStates, dest) = enumerate_paths(state, [dest])[1]
enumerate_paths(state::BellmanFordStates) = enumerate_paths(state, [1:length(state.parents)])
