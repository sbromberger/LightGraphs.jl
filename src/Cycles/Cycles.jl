module Cycles

using LightGraphs
using LightGraphs.Degeneracy
using SimpleTraits

abstract type SimpleCycleAlgorithm end


include("basis.jl")
include("hawick-james.jl")
include("johnson.jl")
include("karp.jl")
include("limited_length.jl")

"""
    simple_cycles(g, alg=Johnson())

Find circuits (including self-loops) in graph `g` using a
specified `SimpleCycleAlgorithm`.
"""
function simple_cycles end
@traitfn simple_cycles(g::::IsDirected) = simple_cycles(g, Johnson())

"""
    ncycles_n_i(n::Integer, i::Integer)

Compute the theoretical maximum number of cycles of size `i` in a directed graph of `n`
 vertices.
"""
ncycles_n_i(n::Integer, i::Integer) = binomial(big(n), big(n - i + 1)) * factorial(big(n - i))

"""
    max_simple_cycles(n::Integer)

Compute the theoretical maximum number of cycles in a directed graph of `n` vertices,
assuming there are no self-loops.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007).
"""
max_simple_cycles(n::Integer) = sum(x -> ncycles_n_i(n, x), 1:(n - 1))

"""
    count_simple_cycles(dg::DiGraph, ::SimpleCyclesAlgorithm)

Count the number of cycles in a directed graph, using a specific algorithm (default:
`Johnson`). Return the minimum of the ceiling and the number of cycles.

### Implementation Notes
If the algorithm supports it, the `ceiling` parameter of the `SimpleCycleAlgorithm` structure may be
used to avoid memory overload if there are a lot of cycles in the graph. You can use the function
[`max_simple_cycles()`](@ref) to get an idea of the theoretical maximum number or cycles.

# Examples
```jldoctest
julia> simple_cycles_count(complete_digraph(6))
409
```
"""
function count_simple_cycles end
@traitfn count_simple_cycles(g::::IsDirected) = count_simple_cycles(g, Johnson())

"""
    minimum_cycle_mean(g[, distmx], alg::SimpleCycleAlgorithm=Karp())

Return minimum cycle mean of the directed graph `g` with optional edge weights contained in `distmx`.
Uses Karp's algorithm by default.

### References
- [Karp](http://dx.doi.org/10.1016/0012-365X(78)90011-0).
"""
function minimum_cycle_mean end
@traitfn minimum_cycle_mean(g::::IsDirected, distmx=weights(g)) = minimum_cycle_mean(g, distmx, Karp())

"""
    simple_cycles_length(dg::DiGraph, alg::SimpleCycleAlgorithm=Johnson())

Search all cycles of the given directed graph, using an appropriate `SimpleCycleAlgorithm`
(default: `Johnson`). Return a tuple representing the cycle length and the number of cycles.

### Implementation Notes
If the algorithm supports it, the `ceiling` parameter of the `SimpleCycleAlgorithm` structure may be
used to avoid memory overload if there are a lot of cycles in the graph. You can use the function
[`max_simple_cycles()`](@ref) to get an idea of the theoretical maximum number or cycles.
If the `ceiling` is reached (`ncycles = ceiling`), the output is only a subset of the cycles lengths.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)

# Examples
```jldoctest
julia> simple_cycles_length(complete_digraph(16), Johnson())
([0, 1, 1, 1, 1, 1, 2, 10, 73, 511, 3066, 15329, 61313, 183939, 367876, 367876], 1000000)

julia> simple_cycles_length(wheel_digraph(16))
([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], 1)
```
"""
function simple_cycles_length end
@traitfn simple_cycles_length(dg::::IsDirected) = simple_cycles_length(dg, Johnson())


# export HawickJames, Johnson, LimitedLength, Karp
# export cycle_basis, simple_cycles, count_simple_cycles, max_simple_cycles, simple_cycles_length
# export minimum_cycle_mean

end # module
