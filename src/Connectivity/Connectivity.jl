module Connectivity

using LightGraphs
using LightGraphs.ShortestPaths
using LightGraphs.Traversals
using DataStructures: Queue, dequeue!, enqueue!, IntDisjointSets, find_root!, union!
using SimpleTraits
import LightGraphs.Traversals: initfn!, newvisitfn!, postlevelfn!, visitfn!, previsitfn!

"""
    abstract type ConnectivityAlgorithm

`ConnectivityAlgorithm` is the abstract type used to specify the connected components algorhim.
"""
abstract type ConnectivityAlgorithm end

"""
    abstract type StrongConnectivityAlgorithm

`StrongConnectivityAlgorithm` is the abstract type used to specify the strongly connected components algorithm.
"""
abstract type StrongConnectivityAlgorithm <: ConnectivityAlgorithm end

"""
    abstract type WeakConnectivityAlgorithm

`WeakConnectivityAlgorithm` is the abstract type used to specify a weakly connected components algorithm for
directed graphs and all algorithms for undirected graphs.
"""
abstract type WeakConnectivityAlgorithm <: ConnectivityAlgorithm end

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
    is_connected(g, alg)

Return `true` if graph `g` is connected, using [`ConnectivityAlgorithm`](@ref) `alg`.

For undirected graphs, `alg` defaults to [`UnionMerge`](@ref). For directed graphs,
strong connectivity using [`Tarjan`](@ref) is the default. (Use a non-strong
[`ConnectivityAlgorithm`](@ref) such as [`UnionMerge`](@ref) or [`DFS`](@ref) to test
for weak connectivity.

# Examples
```jldoctest
julia> g = SimpleGraph([0 1 0; 1 0 1; 0 1 0]);

julia> is_connected(g)
true

julia> g = SimpleGraph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> is_connected(g, DFS())
false

julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_connected(g, UnionMerge())  # weak connectivity
true
```
"""
function is_connected end
function is_connected(g::AbstractGraph, alg::WeakConnectivityAlgorithm=UnionMerge())
    mult = is_directed(g) ? 2 : 1
    return mult*ne(g) +1 >= nv(g) && length(connected_components(g, alg)) == 1
end

@traitfn is_connected(g::::IsDirected, alg::StrongConnectivityAlgorithm=Tarjan()) =
    length(connected_components(g, alg)) == 1
    
"""
    connected_components(g, alg::ConnectivityAlgorithm)

Compute the connected components of a graph `g` using algorithm `alg`.
For undirected graphs, `alg` must be a [`WeakConnectivityAlgorithm`](@ref).
For directed graphs, use a [`WeakConnectivityAlgorithm`](@ref) for
weakly-connected components, or a [`StrongConnectivityAlgorithm`](@ref)
for strongly-connected components.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> connected_components(g, Tarjan())
2-element Array{Array{Int64,1},1}:
 [3]
 [1, 2]


julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list = [(1, 2), (2, 3), (3, 4), (4, 1), (3, 5), (5, 6), (6, 7), (7, 5), (5, 8), (8, 9), (9, 8), (10, 11), (11, 10)];

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> connected_components(g, Tarjan())
4-element Array{Array{Int64,1},1}:
 [8, 9]
 [5, 6, 7]
 [1, 2, 3, 4]
 [10, 11]

julia> g=SimpleDiGraph(3)
{3, 0} directed simple Int64 graph

julia> g = SimpleDiGraph([0 1 0 ; 0 0 1; 0 0 0])
{3, 2} directed simple Int64 graph

julia> connected_components(g, Kosaraju())
3-element Array{Array{Int64,1},1}:
 [1]
 [2]
 [3]

julia> g=SimpleDiGraph(11)
{11, 0} directed simple Int64 graph

julia> edge_list=[(1, 2), (2, 3), (3, 4), (4, 1), (3, 5), (5, 6), (6, 7), (7, 5), (5, 8), (8, 9), (9, 8), (10, 11), (11, 10)];

julia> g = SimpleDiGraph(Edge.(edge_list))
{11, 13} directed simple Int64 graph

julia> connected_components(g, Kosaraju())
4-element Array{Array{Int64,1},1}:
 [11, 10]
 [2, 3, 4, 1]
 [6, 7, 5]
 [9, 8]
```
"""
function connected_components end
@traitfn connected_components(g::::(!IsDirected)) = connected_components(g, UnionMerge())
@traitfn connected_components(g::::IsDirected) = connected_components(g, Tarjan())

"""
    period(g, alg=Tarjan())

Return the (common) period for all vertices in a strongly connected directed graph.
Use [`StrongConnectivityAlgorithm`](@ref) `alg` (defaults to [`Tarjan`](@ref).
Will throw an error if the graph is not strongly connected.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> period(g)
3
```
"""
function period end
@traitfn function period(g::AG::IsDirected, alg::StrongConnectivityAlgorithm=Tarjan()) where {T, AG <: AbstractGraph{T}}
    !is_connected(g, alg) && throw(ArgumentError("Graph must be strongly connected"))

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = LightGraphs.Traversals.tree(g, 1, LightGraphs.Traversals.BreadthFirst())
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
    condensation(g, scc)
    condensation(g, alg=Tarjan())

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first using [`StrongConnectivityAlgorithm`](@ref) `alg`.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> connected_components(g, Tarjan())
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> collect(edges(condensation(g)))
1-element Array{LightGraphs.SimpleGraphs.SimpleEdge{Int64},1}:
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
@traitfn condensation(g::::IsDirected, alg::StrongConnectivityAlgorithm=Tarjan()) =
    condensation(g, connected_components(g, alg))

"""
    attracting_components(g, alg=Tarjan())

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`. Use [`StrongConnectivityAlgorithm`](ref)
`alg` when specified (default [`Tarjan`](@ref)).

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> connected_components(g, Tarjan())
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
@traitfn function attracting_components(g::AG::IsDirected, alg::StrongConnectivityAlgorithm=Tarjan()) where {T, AG <: AbstractGraph{T}}
    scc  = connected_components(g, alg)
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

include("dfs.jl")
include("dfsq.jl")
include("kosaraju.jl")
include("neighborhood_dists.jl")
include("tarjan.jl")
include("unionmerge.jl")

end # module
