using LightGraphs
using LightGraphs.Experimental.Traversals
using LightGraphs: AbstractGraph, AbstractEdge
using SimpleTraits
"""
    Biconnections

A state type for depth-first search that finds the biconnected components.
"""
mutable struct Biconnections{E <: AbstractEdge} <: Traversals.AbstractTraversalState
    low::Vector{Int}
    depth::Vector{Int}
    children::Vector{Int}
    stack::Vector{E}
    biconnected_comps::Vector{Vector{E}}
    id::Int
end


@traitfn function Biconnections(g::::(!IsDirected))
    n = nv(g)
    E = Edge{eltype(g)}
    return Biconnections(zeros(Int, n), zeros(Int, n),  zeros(Int, n), Vector{E}(), Vector{Vector{E}}(), 0)
end

@inline function previsitfn!(s::Biconnections{T}, u) where T
    return true
end
@inline function visitfn!(s::Biconnections{T}, u, v) where T
    if s.depth[v] == 0
        s.children[u] += 1
        push!(s.stack, E(min(u, v), max(u, v)))
        s.low[v] = min(s.low[u], s.low[v])

        #Checking the root, and then the non-roots if they are articulation points
        if (u == v && s.children > 1) || (u != v && s.low[v] >= s.depth[u])
            e = E(0, 0)  #Invalid Edge, used for comparison only
            st = Vector{E}()
            while e != E(min(u, v), max(u, v))
                e = pop!(s.stack)
                push!(st, e)
            end
            push!(s.biconnected_comps, st)
        end

        elseif u != v && s.low[u] > s.depth[v]
            push!(s.stack, E(min(u, v), max(u, v)))
            s.low[u] = s.depth[v]
        end
    return true
end
@inline function newvisitfn!(s::Biconnections{T}, u, v) where T
    return true
end
@inline function postvisitfn!(s::Biconnections{T}, u) where T
    s.children[u] = 0
    s.id +=1
    s.depth[u] = s.id
    s.low[u] = s.depth[u]
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
        traverse_graph!(g, [u], DFS(), state, outneighbors)
        if !isempty(state.stack)
            push!(state.biconnected_comps, reverse(state.stack))
            empty!(state.stack)
        end
    end
    return state.biconnected_comps
end
