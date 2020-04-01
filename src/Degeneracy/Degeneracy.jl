module Degeneracy

using LightGraphs

"""
    abstract type CoreAlgorithm

An abstract type representing a specific core decomposition algorithm.
"""
abstract type CoreAlgorithm end

"""
    struct Batagelj <: CoreAlgorithm

A [`CoreAlgorithm`] specifying the single-threaded Batagelj decomposition algorithm.

### References
* An O(m) Algorithm for Cores Decomposition of Networks,
    Vladimir Batagelj and Matjaz Zaversnik, 2003.
    http://arxiv.org/abs/cs.DS/0310049
"""
struct Batagelj <: CoreAlgorithm end

"""
    struct ThreadedBatagelj <: CoreAlgorithm

A [`CoreAlgorithm`] specifying the multithreaded Batagelj decomposition algorithm.

### References
* An O(m) Algorithm for Cores Decomposition of Networks,
    Vladimir Batagelj and Matjaz Zaversnik, 2003.
    http://arxiv.org/abs/cs.DS/0310049
"""
struct ThreadedBatagelj <: CoreAlgorithm end

"""
    abstract type Decomposition

An abstract type representing a specific graph decomposition strategy. Strategies include
- [`KCore`](@ref)
- [`KCorona`](@ref)
- [`KCrust`](@ref)
- [`KShell`](@ref)
"""
abstract type Decomposition end

"""
    struct KCore <: Decomposition

Struct representing the k-core of a graph. A k-core is a maximal subgraph that
contains vertices of degree `k` or more.

### Optional Parameters
`k::T`: if `k` is not specified, the graph's maximum [core number](@ref core_number) is used.
`alg::CoreAlgorithm`: the [`CoreAlgorithm`](@ref) used to calculate the [core number](@ref core_number)
    if this vector is not otherwise provided.

### Implementation Notes
Not implemented for graphs with self loops.

"""
struct KCore{T, C} <: Decomposition
    k::T
    alg::C
end
KCore(;k=-1, alg=Batagelj()) = KCore(k, alg)
KCore(k::Integer) = KCore(k, Batagelj())

"""
    struct KCorona <: Decomposition

Struct representing a k-corona decomposition of a graph.

The k-corona is the subgraph of vertices in the [k-core](@ref KCore) which
have exactly `k` neighbors in the k-core.

### Optional Parameters
`k<:Integer`: if `k` is not specified, the graph's maximum [core number](@ref core_number) is used.
`alg<:CoreAlgorithm`: the [`CoreAlgorithm`](@ref) used to calculate the [core number](@ref core_number)
    if this vector is not otherwise provided.

### Implementation Notes
Not implemented for graphs with parallel edges or self loops.

### References
- k-core (bootstrap) percolation on complex networks:
   Critical phenomena and nonlocal effects,
   A. V. Goltsev, S. N. Dorogovtsev, and J. F. F. Mendes,
   Phys. Rev. E 73, 056101 (2006)
   http://link.aps.org/doi/10.1103/PhysRevE.73.056101
"""
struct KCorona{T, C} <: Decomposition
    k::T
    alg::C
end
KCorona(;k=-1, alg=Batagelj()) = KCorona(k, alg)
KCorona(k::Integer) = KCorona(k, Batagelj())

"""
    struct KCrust <: Decomposition

Struct representing a k-crust decomposition of a graph.

The k-crust is the graph `g` with the [k-core](@ref KCore) removed.

### Implementation Notes
This definition of k-crust is different than the definition in References.
The k-crust in References is equivalent to the `k+1` crust of this algorithm.

Not implemented for graphs with self loops.

### Optional Parameters
`k<:Integer`: if `k` is not specified, the graph's maximum [core number](@ref core_number) is used.
`alg<:CoreAlgorithm`: the [`CoreAlgorithm`](@ref) used to calculate the [core number](@ref core_number)
    if this vector is not otherwise provided.

### References
- A model of Internet topology using k-shell decomposition
   Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,
   and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154
   http://www.pnas.org/content/104/27/11150.full

"""
struct KCrust{T, C} <: Decomposition
    k::T
    alg::C
end
KCrust(;k=-1, alg=Batagelj()) = KCrust(k, alg)
KCrust(k::Integer) = KCrust(k, Batagelj())

"""
    struct KShell <: Decomposition

Struct representing a k-shell decomposition of a graph.

The k-shell is the subgraph of vertices in the `k`-core but not in
the (`k+1`)-core. This is similar to k-corona but in that case
only neighbors in the k-core are considered.

### Optional Parameters
`k<:Integer`: if `k` is not specified, the graph's maximum [core number](@ref core_number) is used.
`alg<:CoreAlgorithm`: the [`CoreAlgorithm`](@ref) used to calculate the [core number](@ref core_number)
    if this vector is not otherwise provided.

### Implementation Notes
Not implemented for graphs with parallel edges or self loops.

### References
- A model of Internet topology using k-shell decomposition
   Shai Carmi, Shlomo Havlin, Scott Kirkpatrick, Yuval Shavitt,
   and Eran Shir, PNAS  July 3, 2007   vol. 104  no. 27  11150-11154
   http://www.pnas.org/content/104/27/11150.full
"""
struct KShell{T, C} <: Decomposition
    k::T
    alg::C
end
KShell(;k=-1, alg=Batagelj()) = KShell(k, alg)
KShell(k::Integer) = KShell(k, Batagelj())

"""
    core_number(g, alg=Batagelj())

Return the core number for each vertex in graph `g` using [`CoreAlgorithm`](@ref)
algorithm `alg`.

The core number of a vertex is the largest value `k` of a k-core containing
that vertex. A k-core is a maximal subgraph that contains vertices of
degree `k` or more.

### Implementation Notes
Not implemented for graphs with self loops.

# Examples
```jldoctest
julia> using LightGraphs

julia> g = path_graph(5);

julia> add_vertex!(g);

julia> add_edge!(g, 5, 2);

julia> core_number(g)
6-element Array{Int64,1}:
 1
 2
 2
 2
 2
 0
```
"""
core_number(g::AbstractGraph) = core_number(g, Batagelj())

"""
    decompose(g, d)
    decompose(g, d, cn)

Decompose a graph `g` using [graph decomposition](@ref Decomposition) type `d`.
If a vector representing the graph's [core number](@ref core_number) is provided, it
will be used; otherwise, the core number will be calcuated as part of the decomposition.
"""
decompose(g::AbstractGraph, d::Decomposition) = decompose(g, d, core_number(g, d.alg))

function decompose(g::AbstractGraph{T}, d::KCore, cn::AbstractVector) where {T}
    k = d.k == -1 ? T(maximum(cn)) : T(d.k)
    T.(findall(x -> x >= k, cn))
end

function decompose(g::AbstractGraph{T}, d::KShell, cn::AbstractVector) where {T}
    k = d.k == -1 ?  T(maximum(cn)) : T(d.k)
    return T.(findall(x -> x == k, cn))
end

function decompose(g::AbstractGraph{T}, d::KCrust, cn::AbstractVector) where {T}
    k = d.k == -1 ? T(maximum(cn)) - one(T) : T(d.k)
    return T.(findall(x -> x <= k, cn))
end

function decompose(g::AbstractGraph{T}, d::KCorona, cn::AbstractVector) where {T}
    k = d.k == -1 ? T(maximum(cn)) : T(d.k)
    kcorealg = KCore(k=k, alg=d.alg)
    kcore = decompose(g, kcorealg, cn)
    kcoreg = g[kcore]
    kcoredeg = T.(degree(kcoreg))

    return kcore[findall(x-> x == k, kcoredeg)]
end

include("batagelj.jl")

end # module
