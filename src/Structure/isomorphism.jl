"""
    abstract type IsomorphismScope

An abstract type describing the scope of an isomorphism problem.
"""
abstract type IsomorphismScope end

"""
    struct FullGraph <: IsomorphismScope

A [`IsomorphismScope`](@ref) specifying a full graph isomorphism comparison
(given two graphs, if the first is isomorphic to the second).
"""
struct FullGraph <: IsomorphismScope end

"""
    struct Subgraph <: IsomorphismScope

A [`IsomorphismScope`](@ref) specifying a subgraph isomorphism comparison
(given two graphs, if the first contains a subgraph that is isomorphic to the second).
"""
struct Subgraph <: IsomorphismScope end
"""
    struct InducedSubgraph <: IsomorphismScope

A [`IsomorphismScope`](@ref) specifying a subgraph isomorphism comparison
(given two graphs, if the first contains a vertex induced subgraph that is isomorphic to the second).
"""
struct InducedSubgraph <: IsomorphismScope end

"""
    abstract type IsomorphismAlgorithm

An abstract type used for method dispatch on isomorphism functions.
"""
abstract type IsomorphismAlgorithm end


"""
    could_have_isomorph(g1, g2)

Run quick test to check if `g1 and `g2` could be isomorphic.

If the result is `false`, then `g1` and `g2` are definitely not isomorphic,
but if the result is `true` this is not guaranteed.

# Examples
```jldoctest
julia> using LightGraphs

julia> could_have_isomorph(SimpleGraph(Generators.Path(3))), SimpleGraph(Generators.Star(4))))
false

julia> could_have_isomorph(SimpleGraph(Generators.Path(3))), SimpleGraph(Generators.Star(3))))
true
```
"""
function could_have_isomorph(g1::AbstractGraph, g2::AbstractGraph)
    nv(g1) == nv(g2) || return false

    indegs1 = indegree(g1)
    indegs2 = indegree(g2)
    sort!(indegs1)
    sort!(indegs2)
    indegs1 == indegs2 || return false

    if LightGraphs.is_directed(g1) || LightGraphs.is_directed(g2)
        outdegs1 = outdegree(g1)
        outdegs2 = outdegree(g2)
        sort!(outdegs1)
        sort!(outdegs2)
        outdegs1 == outdegs2 || return false
    end

    return true
end

"""
    has_isomorph(g1, g2, scope::IsomorphismScope, alg::IsomorphismAlgorithm=VF2())

Return `true` if the graph `g1` is isomorphic to `g2` within the scope defined by [`IsomorphismScope`].

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.

### Examples
```doctest.jl
julia> has_isomorph(SimpleGraph(Generators.Complete(5))), SimpleGraph(Generators.Complete(4))), InducedSubgraph())
true
julia> has_isomorph(SimpleGraph(Generators.Complete(5))), SimpleGraph(Generators.Cycle(4))))
false

julia> g1 = SimpleDiGraph(Generators.Path(3))); color1 = [1, 1, 1]
julia> g2 = SimpleDiGraph(Generators.Path(2))); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> has_isomorph(g1, g2, InducedSubgraph())
true
julia> has_isomorph(g1, g2, InducedSubgraph(), VF2(vertex_relation=color_rel))
false
julia> has_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Complete(4)), SubGraph())
true
julia> has_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Cycle(4)), SubGraph())
true
julia> has_isomorph(SimpleGraph(Generators.Complete(3)), SimpleGraph(Generators.Cycle(3)), FullGraph())
true
julia> has_isomorph(SimpleGraph(Generators.Complete(4)), SimpleGraph(Generators.Cycle(4)), FullGraph())
false
```
### See also
[`count_isomorph`](@ref), [`all_isomorph`](@ref)
"""
function has_isomorph end
has_isomorph(g1::AbstractGraph, g2::AbstractGraph, scope::IsomorphismScope) = has_isomorph(g1, g2, scope, VF2())


"""
    count_isomorph(g1, g2, scope::IsomorphismScope, alg::IsomorphismAlgorithm=VF2())

Return a count of isomorphisms between `g1` and `g2` within the [`IsomorphismSope`](@ref) defined by `scope`.

### Examples
```doctest.jl
julia> count_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Complete(4)), InducedSubgraph())
120
julia> count_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Cycle(4)), InducedSubgraph())
0

julia> g1 = SimpleGraph(Generators.Path(3))); color1 = [1, 1, 2]
julia> g2 = SimpleGraph(Generators.Path(2))); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> count_isomorph(g1, g2, InducedSubgraph())
2
julia> count_isomorph(g1, g2, InducedSubgraph(), VF2(vertex_relation=color_rel))
1

julia> count_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Complete(4)), SubGraph())
120
julia> count_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Cycle(4)), SubGraph())
120
julia> count_isomorph(SimpleGraph(Generators.Cycle(5)), SimpleGraph(Generators.Cycle(5)), FullGraph())
10
julia> count_isomorph(SimpleGraph(Generators.Complete(5)), SimpleGraph(Generators.Cycle(5)), FullGraph())
0
```
### See also
[`has_isomorph`](@ref), [`all_isomorph`](@ref)
"""
function count_isomorph end
count_isomorph(g1::AbstractGraph, g2::AbstractGraph, scope::IsomorphismScope) =
    count_isomorph(g1, g2, scope, VF2())

"""
    all_isomorph(g1, g2, scope::IsomorphismScope, alg::IsomorphismAlgorithm=VF2())

Return all isomorphisms from `g1` to `g2` within an [`IsomorphismScope`] defined by `scope`.
The isomorphisms are returned as an iterator of vectors of tuples, where the i-th vector is
the i-th isomorphism and a tuple (u, v) in this vector means that u ∈ g1 is
mapped to v ∈ g2.

### Optional Arguments
- `alg`: The algorithm that is used to find the induced subgraph isomorphism. Can be only
    `VF2()` at the moment.

### Examples
```doctest.jl
julia> all_isomorph(SimpleGraph(Generators.Path(3)), SimpleGraph(2), InducedSubgraph()) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (3, 2)]
 [(3, 1), (1, 2)]

julia> g1 = SimpleDiGraph(Generators.Path(3)); color1 = [1, 1, 2]
julia> g2 = SimpleDiGraph(Generators.Path(2)); color2 = [1, 2]
julia> color_rel(u, v) = (color1[u] == color2[v])
julia> all_isomorph(g1, g2, InducedSubgraph()) |> collect
2-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (3, 2)]
julia> all_isomorph(g1, g2, InducedSubgraph(), VF2(vertex_relation=color_rel)) |> collect
1-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
julia> all_isomorph(SimpleGraph(Generators.Path(3)), SimpleGraph(Generators.Path(2)), Subgraph()) |> collect
4-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2)]
 [(2, 1), (1, 2)]
 [(2, 1), (3, 2)]
 [(3, 1), (2, 2)]
julia> all_isomorph(SimpleGraph(Generators.Star(4)), SimpleGraph(Generators.Star(4)), FullGraph()) |> collect
6-element Array{Array{Tuple{Int64,Int64},1},1}:
 [(1, 1), (2, 2), (3, 3), (4, 4)]
 [(1, 1), (2, 2), (4, 3), (3, 4)]
 [(1, 1), (3, 2), (2, 3), (4, 4)]
 [(1, 1), (3, 2), (4, 3), (2, 4)]
 [(1, 1), (4, 2), (2, 3), (3, 4)]
 [(1, 1), (4, 2), (3, 3), (2, 4)]

```
### See also
[`has_isomorph`](@ref), [`count_isomorph`](@ref)
"""
function all_isomorph end
all_isomorph(g1::AbstractGraph, g2::AbstractGraph, scope::IsomorphismScope) = all_isomorph(g1, g2, scope, VF2())

