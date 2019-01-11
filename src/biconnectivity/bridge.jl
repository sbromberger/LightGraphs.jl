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
    T = eltype(g)
    return Bridges(zeros(T, n), zeros(T, n), Edge{T}[], zero(T))
end

"""
    visit!(state, g, u, v)
Perform a depth first search storing the depth (in `depth`) and low-points
(in `low`) of each vertex.
"""
function visit!(state::Bridges, g::AbstractGraph, u::Integer, v::Integer)
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    @inbounds for w in outneighbors(g, v)
        if state.depth[w] == 0
            visit!(state, g, v, w)

            state.low[v] = min(state.low[v], state.low[w])
            if state.low[w] > state.depth[v]
                edge = v < w ? Edge(v, w) : Edge(w, v)
                push!(state.bridges, edge)
            end

        elseif w != u
            state.low[v] = min(state.low[v], state.depth[w])
        end
    end
end

"""
    bridges(g)
Compute the [bridges](https://en.m.wikipedia.org/wiki/Bridge_(graph_theory))
of a connected graph `g` and return an array containing all bridges, i.e edges
whose deletion increases the number of connected components of the graph.
# Examples
```jldoctest
julia> using LightGraphs

julia> bridges(StarGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 1 => 2
 Edge 1 => 3
 Edge 1 => 4
 Edge 1 => 5

julia> bridges(PathGraph(5))
8-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
 Edge 4 => 5
 Edge 3 => 4
 Edge 2 => 3
 Edge 1 => 2
```
"""
function bridges(g::AbstractGraph{<:Integer})
    is_directed(g) && throw(ArgumentError("bridges is only implemented for undirected graphs"))
    state = Bridges(g)
    for u in vertices(g)
        if state.depth[u] == 0
            visit!(state, g, u, u)
        end
    end
    return state.bridges
end
