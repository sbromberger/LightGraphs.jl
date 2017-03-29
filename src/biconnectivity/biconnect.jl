"""
    Biconnections

A state type for depth-first search that finds the biconnected components.
"""
mutable struct Biconnections
    low::Vector{Int}
    depth::Vector{Int}
    stack::Vector{Edge}
    biconnected_comps::Vector{Vector{Edge}}
    id::Int
end

@traitfn function Biconnections(g::::(!IsDirected))
    n = nv(g)
    return Biconnections(zeros(Int, n), zeros(Int, n), Vector{Edge}(), Vector{Vector{Edge}}(), 0)
end


"""
    visit!(g, state, u, v)

Perform a DFS visit storing the depth and low-points of each vertex.
"""
function visit!(g::AbstractGraph, state::Biconnections, u::Integer, v::Integer)
    children = 0
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    for w in out_neighbors(g, v)
        if state.depth[w] == 0
            children += 1
            push!(state.stack, Edge(min(v, w), max(v, w)))
            visit!(g, state, v, w)
            state.low[v] = min(state.low[v], state.low[w])

            #Checking the root, and then the non-roots if they are articulation points
            if (u == v && children > 1) || (u != v && state.low[w] >= state.depth[v])
                e = Edge(0, 0)  #Invalid Edge, used for comparison only
                st = Vector{Edge}()
                while e != Edge(min(v, w),max(v, w))
                    e = pop!(state.stack)
                    push!(st, e)
                end
                push!(state.biconnected_comps, st)
            end

        elseif w != u && state.low[v] > state.depth[w]
            push!(state.stack, Edge(min(v, w), max(v, w)))
            state.low[v] = state.depth[w]
        end
    end
end

@doc_str """
    biconnected_components(g)

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.
"""
function biconnected_components end
@traitfn function biconnected_components(g::::(!IsDirected))
    state = Biconnections(g)
    for u in vertices(g)
        if state.depth[u] == 0
            visit!(g, state, u, u)
        end

        if !isempty(state.stack)
            push!(state.biconnected_comps, reverse(state.stack))
            empty!(state.stack)
        end
    end
    return state.biconnected_comps
end
