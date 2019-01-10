"""
    Bridges{T}
A state type for the depth-first search that finds bridges in a graph.
"""
mutable struct Bridges{T<:Integer}
    low::Vector{T}
    depth::Vector{T}
    bridges::Vector{Edge{T}}
    id::T
end

function Bridges(g::AbstractGraph)
    n = nv(g)
    T = typeof(n)
    return Bridges(zeros(T, n), zeros(T, n), Edge{T}[], zero(T))
end

"""
    visit!(state, g, u, v)
Perform a depth first search storing the depth (in `depth`) and low-points
(in `low`) of each vertex.
"""
function visit!(state::Bridges, g::AbstractGraph, u::Integer, v::Integer)
    children = 0
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    for w in outneighbors(g, v)
        if state.depth[w] == 0
            children += 1
            visit!(state, g, v, w)

            state.low[v] = min(state.low[v], state.low[w])
            if state.low[w] > state.depth[v]
                push!(state.bridges, Edge(v, w))
                push!(state.bridges, Edge(w, v))
            end

        elseif w != u
            state.low[v] = min(state.low[v], state.depth[w])
        end
    end
end

"""
    bridge(g)
Compute the [bridges](https://en.m.wikipedia.org/wiki/Bridge_(graph_theory))
of a connected graph `g` and return an array containing all bridges.
# Examples
```jldoctest
julia> using LightGraphs

julia> bridge(StarGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 2 => 1
 Edge 1 => 3
 Edge 3 => 1
 Edge 1 => 4
 Edge 4 => 1
 Edge 1 => 5
 Edge 5 => 1

julia> bridge(PathGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 4 => 5
 Edge 5 => 4
 Edge 3 => 4
 Edge 4 => 3
 Edge 2 => 3
 Edge 3 => 2
 Edge 1 => 2
 Edge 2 => 1
```
"""
function bridge(g::AbstractGraph)
    state = Bridges(g)
    for u in vertices(g)
        if state.depth[u] == 0
            visit!(state, g, u, u)
        end
    end
    return state.bridges
end
