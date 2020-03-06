using LightGraphs
using LightGraphs.Experimental
using LightGraphs: AbstractGraph, AbstractEdge
using SimpleTraits
"""
    Biconnections

A state type for depth-first search that finds the biconnected components.
"""
mutable struct Biconnections{E <: AbstractEdge} <: Traversals.AbstractTraversalState
    low::Vector{Int}
    discovery::Vector{Int}
    grandparent::Int
    stack::Vector{E}
    biconnected_comps::Vector{Vector{E}}
    id::Int
end


@traitfn function Biconnections(g::::(!IsDirected))
    n = nv(g)
    E = Edge{eltype(g)}
    return Biconnections(zeros(Int, n), zeros(Int, n), 0, Vector{E}(), Vector{Vector{E}}(), 0)
end

@inline function visitfn!(s::Biconnections{E}, u, v) where E
    if s.grandparent != v
        if s.discovery[v] > 0
            if s.discovery[v] <= s.discovery[u]
                s.low[u] = min(s.low[u], s.discovery[v])
                push!(s.stack, E(min(u, v), max(u, v)))
            end
        else
            push!(s.stack, E(min(u, v), max(u, v)))
        end
    end
    return true
end

@inline function newvisitfn!(s::Biconnections{E}, u, v) where E
    if s.grandparent != v
        s.id += 1
        s.discovery[u] = s.id
        s.low[u] = s.id
    end
    return true
end

@inline function postvisitfn!(s::Biconnections{E}, v) where E
    s.grandparent = v
    if s.low[v] >= s.discovery[s.grandparent]
        if !isempty(s.stack)
            push!(s.biconnected_comps, reverse(s.stack))
            empty!(s.stack)
        end
    end
    return true
end


"""
    biconnected_components2(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components2(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components2(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""
function biconnected_components2 end
@traitfn function biconnected_components2(g::::(!IsDirected))
    state = Biconnections(g)
    for u in 1:nv(g)
        if state.discovery[u] == 0
            Traversals.traverse_graph!(g, [u], Traversals.DFS(), state, outneighbors)
        end
    end
    return state.biconnected_comps
end
