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

function create_bellman_ford_states(g::AbstractGraph)
    n = nv(g)
    parents = zeros(Int, n)
    dists = fill(typemax(Float64), n)

    BellmanFordStates(parents, dists)
end

function bellman_ford_shortest_paths!(
    graph::AbstractGraph,
    edge_dists::AbstractArray{Float64, 2},
    sources::AbstractVector{Int},
    state::BellmanFordStates)

    use_dists = issparse(edge_dists)? nnz(edge_dists > 0) : !isempty(edge_dists)

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
                if use_dists
                    edist = edge_dists[src(e), dst(e)]
                    if edist == 0.0
                        edist = 1.0
                    end
                else
                    edist = 1.0
                end

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
    graph::AbstractGraph,

    sources::AbstractVector{Int};
    edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))
    )

    state = create_bellman_ford_states(graph)
    bellman_ford_shortest_paths!(graph, edge_dists, sources, state)
end

bellman_ford_shortest_paths(graph::AbstractGraph, v::Int; edge_dists::AbstractArray{Float64, 2} = Array(Float64,(0,0))) = bellman_ford_shortest_paths(graph, [v]; edge_dists=edge_dists)

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
