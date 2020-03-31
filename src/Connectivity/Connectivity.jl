module Connectivity
# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
using LightGraphs
using LightGraphs.ShortestPaths
using LightGraphs.Traversals
using DataStructures: Queue, dequeue!, enqueue!
using SimpleTraits
import LightGraphs.Traversals: initfn!, newvisitfn!, postlevelfn!, visitfn!, previsitfn!

"""
    abstract type ConnectivityAlgorithm

`ConnectivityAlgorithm` is the abstract type used to specify the connected components algorhim.
"""
abstract type ConnectivityAlgorithm end

"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in the undirected graph
`g` to which it belongs. Return a vector representing the component assigned
to each vertex. The component value is the smallest vertex ID in the component.

### Performance
This algorithm is linear in the number of edges of the graph.
"""
function connected_components!(label::AbstractVector, g::AbstractGraph{T}) where T
    nvg = nv(g)
    Q = Queue{T}()
    @inbounds for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        enqueue!(Q, u)
        while !isempty(Q)
            src = dequeue!(Q)
            for vertex in all_neighbors(g, src)
                if label[vertex] == zero(T)
                    enqueue!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end


"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a map with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where T <: Integer
    d = Dict{T,Vector{T}}()
    for (v, l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::AbstractVector{T}) where {T <: Integer}
    d = Dict{T,T}()
    c = Vector{Vector{T}}()
    i = one(T)
    for (v, l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, with each element a vector of vertices
belonging to the component.

For directed graphs, see [`strongly_connected_components`](@ref) and
[`weakly_connected_components`](@ref).

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> connected_components(g)
2-element Array{Array{Int64,1},1}:
 [1, 2, 3]
 [4, 5]
```
"""
function connected_components(g::AbstractGraph{T}) where T
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if graph `g` is connected. For directed graphs, return `true`
if graph `g` is weakly connected.

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> is_connected(g)
true

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> is_connected(g)
false

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_connected(g)
true
```
"""
function is_connected(g::AbstractGraph)
    mult = is_directed(g) ? 2 : 1
    return mult * ne(g) + 1 >= nv(g) && length(connected_components(g)) == 1
end

"""
    weakly_connected_components(g)

Return the weakly connected components of the graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
For undirected graphs this is equivalent to the [`connected_components`](@ref) of `g`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> weakly_connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]
```
"""
weakly_connected_components(g) = connected_components(g)

"""
    is_weakly_connected(g)

Return `true` if the graph `g` is weakly connected. If `g` is undirected,
this function is equivalent to [`is_connected(g)`](@ref).

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_weakly_connected(g)
true

julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> is_connected(g)
true

julia> is_strongly_connected(g)
false

julia> is_weakly_connected(g)
true
```
"""
is_weakly_connected(g) = is_connected(g)


mutable struct SccState{T<:Integer} <: LightGraphs.Traversals.TraversalState
    lastnode::T
    up::Bool
    stack::Vector{T}
    low::Vector{T}
    order::Vector{T}
    onstack::BitVector
    cnt::T
    comps::Vector{Vector{T}}
end

@inline function initfn!(s::SccState, u)
    s.up = false
    push!(s.stack, u)
    return true
end


@inline function previsitfn!(s::SccState{T}, u) where T
    if  s.up
        s.low[u] = min(s.low[u], s.low[s.lastnode])
    else
        push!(s.stack, u)
        s.up = true
        s.onstack[u] = true
        s.cnt += one(T)
        s.low[u] = s.order[u] = s.cnt
    end
    s.lastnode = u
    return true
end

@inline function newvisitfn!(s::SccState, u, v)
    s.up = false
    return true
end

@inline function visitfn!(s::SccState, u, v)
    if s.onstack[v]
        s.low[u] = min(s.order[v], s.low[u])
    end
    return true
end

@inline function postlevelfn!(s::SccState{T}) where T
    v = s.lastnode
    if s.low[v] == s.order[v]
        new_component = Vector{T}()
        a = T(0)
        while a != v
            a = pop!(s.stack)
            s.onstack[a] = false
            push!(new_component, a)
        end
        reverse!(new_component)
        push!(s.comps, new_component)
    end
    return true
end


"""
    abstract type StrongConnectivityAlgorithm

`StrongConnectivityAlgorithm` is the abstract type used to specify the strongly connected components algorithm.
"""
abstract type StrongConnectivityAlgorithm <: ConnectivityAlgorithm end

"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [3]
 [1, 2]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)];

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components(g)
4-element Array{Array{Int64,1},1}:
 [8, 9]
 [5, 6, 7]
 [1, 2, 3, 4]
 [10, 11]
```
"""


function strongly_connected_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function strongly_connected_components(g::AG::IsDirected) where {T<:Integer, AG <: AbstractGraph{T}}
    state = SccState(T(0), false, Vector{T}(), zeros(T, nv(g)), zeros(T, nv(g)), falses(nv(g)), T(0), Vector{Vector{T}}())
    LightGraphs.Traversals.traverse_graph!(g, vertices(g), LightGraphs.Traversals.DepthFirst(), state)
    return state.comps
end

struct Tarjan <: StrongConnectivityAlgorithm end

@traitfn connected_components(g::::IsDirected, ::Tarjan) = strongly_connected_components(g)



mutable struct RevPostOrderState{T <: Integer} <: LightGraphs.Traversals.TraversalState
    cnt::T
    lastnode::T
    result::Vector{T}
end

@inline function previsitfn!(s::RevPostOrderState{T}, u) where T
    s.lastnode = u
    return true
end

@inline function postlevelfn!(s::RevPostOrderState{T}) where T
    s.result[s.cnt] = s.lastnode
    s.cnt -= 1
    return true
end


mutable struct KosarajuState{T <: Integer} <: LightGraphs.Traversals.TraversalState
    curr_comp::Vector{T}
    comps::Vector{Vector{T}}
end

@inline function initfn!(s::KosarajuState{T}, u) where T
    if !isempty(s.curr_comp)
        push!(s.comps, s.curr_comp)
    end
    s.curr_comp = Vector{T}([u])
    return true
end

@inline function newvisitfn!(s::KosarajuState, u, v)
    push!(s.curr_comp, v)
    return true
end








"""
    strongly_connected_components_kosaraju(g)

Compute the strongly connected components of a directed graph `g` using Kosaraju's Algorithm.
(https://en.wikipedia.org/wiki/Kosaraju%27s_algorithm).

Return an array of arrays, each of which is the entire connected component.

### Performance
Time Complexity : O(|E|+|V|)
Space Complexity : O(|V|) {Excluding the memory required for storing graph}

|V| = Number of vertices
|E| = Number of edges

### Examples
```jldoctest

julia> g=SimpleDiGraph(3)
{3, 0} directed simple Int64 graph

julia> g = SimpleDiGraph([0 1 0 ; 0 0 1; 0 0 0])
{3, 2} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
3-element Array{Array{Int64,1},1}:
 [1]
 [2]
 [3]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1,2),(2,3),(3,4),(4,1),(3,5),(5,6),(6,7),(7,5),(5,8),(8,9),(9,8),(10,11),(11,10)]
13-element Array{Tuple{Int64,Int64},1}:
 (1, 2)
 (2, 3)
 (3, 4)
 (4, 1)
 (3, 5)
 (5, 6)
 (6, 7)
 (7, 5)
 (5, 8)
 (8, 9)
 (9, 8)
 (10, 11)
 (11, 10)

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> strongly_connected_components_kosaraju(g)
4-element Array{Array{Int64,1},1}:
 [11, 10]
 [2, 3, 4, 1]
 [6, 7, 5]
 [9, 8]

```
"""

function strongly_connected_components_kosaraju end
@traitfn function strongly_connected_components_kosaraju(g::AG::IsDirected) where {T<:Integer, AG <: AbstractGraph{T}}
    state = RevPostOrderState(nv(g), T(0), zeros(T, nv(g)))
    LightGraphs.Traversals.traverse_graph!(g, vertices(g), LightGraphs.Traversals.DepthFirst(), state)
    state2 = KosarajuState(Vector{T}(), Vector{Vector{T}}())
    LightGraphs.Traversals.traverse_graph!(g, state.result, LightGraphs.Traversals.DepthFirst(neighborfn=inneighbors), state2)
    if !isempty(state2.curr_comp)
        push!(state2.comps, state2.curr_comp)
    end
    return state2.comps
end

struct Kosaraju <: StrongConnectivityAlgorithm end

@traitfn connected_components(g::::IsDirected, ::Kosaraju) = strongly_connected_components_kosaraju(g)


"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_strongly_connected(g)
true
```
"""
function is_strongly_connected end
@traitfn is_strongly_connected(g::::IsDirected) = length(strongly_connected_components(g)) == 1

"""
    period(g)

Return the (common) period for all vertices in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> period(g)
3
```
"""
function period end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function period(g::AG::IsDirected) where {T, AG <: AbstractGraph{T}}
    !is_strongly_connected(g) && throw(ArgumentError("Graph must be strongly connected"))

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g, 1)
    levels      = gdistances(g_bfs_tree, 1)
    tree_diff   = difference(g, g_bfs_tree)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor, value)
        isequal(divisor, 1) && return 1
    end

    return divisor
end

"""
    condensation(g[, scc])

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> foreach(println, edges(condensation(g)))
Edge 2 => 1
```
"""
function condensation end
@traitfn function condensation(g::::IsDirected, scc::Vector{Vector{T}}) where T <: Integer
    h = DiGraph{T}(length(scc))

    component = Vector{T}(undef, nv(g))

    for (i, s) in enumerate(scc)
        @inbounds component[s] .= i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h, s, d)
        end
    end
    return h
end
@traitfn condensation(g::::IsDirected) = condensation(g, strongly_connected_components(g))

"""
    attracting_components(g)

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> attracting_components(g)
1-element Array{Array{Int64,1},1}:
 [4, 5]
```
"""
function attracting_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function attracting_components(g::AG::IsDirected) where {T, AG <: AbstractGraph{T}}
    scc  = strongly_connected_components(g)
    cond = condensation(g, scc)

    attracting = Vector{T}()

    for v in vertices(cond)
        if outdegree(cond, v) == 0
            push!(attracting, v)
        end
    end
    return scc[attracting]
end


"""
    is_graphical(degs)

Return `true` if the degree sequence `degs` is graphical.
A sequence of integers is called graphical, if there exists a graph where the degrees of its vertices form that same sequence.

### Performance
Time complexity: ``\\mathcal{O}(|degs|*\\log(|degs|))``.

### Implementation Notes
According to Erdös-Gallai theorem, a degree sequence ``\\{d_1, ...,d_n\\}`` (sorted in descending order) is graphical iff the sum of vertex degrees is even and the sequence obeys the property -
```math
\\sum_{i=1}^{r} d_i \\leq r(r-1) + \\sum_{i=r+1}^n min(r,d_i)
```
for each integer r <= n-1
"""
function is_graphical(degs::Vector{<:Integer})
    iseven(sum(degs)) || return false
    sorted_degs = sort(degs, rev = true)
    n = length(sorted_degs)
    cur_sum = zero(UInt64)
    mindeg = Vector{UInt64}(undef, n)
    @inbounds for i = 1:n
        mindeg[i] = min(i, sorted_degs[i])
    end
    cum_min = sum(mindeg)
    @inbounds for r = 1:(n - 1)
        cur_sum += sorted_degs[r]
        cum_min -= mindeg[r]
        cond = cur_sum <= (r * (r - 1) + cum_min)
        cond || return false
    end
    return true
end

include("neighborhood_dists.jl")

end # module
