"""
Biconnections: A state type for Depth First Search that finds the biconnected components
"""
type Biconnections
    low::Vector{Int}
    depth::Vector{Int}
    stack::Vector{Edge}
    biconnected_comps::Vector{Vector{Edge}}
    id::Int
end

function Biconnections(g::SimpleGraph)
    n = nv(g)
    return Biconnections(zeros(Int, n), zeros(Int, n), Vector{Edge}(), Vector{Vector{Edge}}(), 0)
end

"""
Computes the biconnected components of a graph `g`
and returns a Vector of vectors containing each biconnected component
"""
function biconnected_components(g::SimpleGraph)
    state = Biconnections(g)
    for u in vertices(g)
        if state.depth[u] == 0
            visit!(g, state, u, u)
        end

        if !isempty(state.stack)
            st = Vector{Edge}()
            while !isempty(state.stack)
                e = pop!(state.stack)
                push!(st, e)
            end
            push!(state.biconnected_comps, st)
        end
    end

    return state.biconnected_comps
end

"""
Does a DFS visit and stores the depth and low-points of each vertex
"""
function visit!(g::SimpleGraph, state::Biconnections, u::Int, v::Int)
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
                e = Edge(0, 0)  #so that min, max are correctly initialized below
                st = Vector{Edge}()
                while e != Edge(min(v, w),max(v, w))
                    e = pop!(state.stack)
                    push!(st, e)
                end
            push!(state.biconnected_comps, st)
            end

        elseif w != u && state.low[v] > state.depth[w]
            push!(state.stack, Edge(min(v, w), max(v, w)))
            state.low[v] = min(state.low[v], state.depth[w])
        end
    end
end
