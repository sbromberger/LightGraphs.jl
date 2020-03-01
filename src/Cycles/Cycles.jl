module Cycles

using LightGraphs
using SimpleTraits

abstract type SimpleCycleAlgorithm end


include("basis.jl")
include("hawick-james.jl")
include("johnson.jl")
include("karp.jl")
include("limited_length.jl")

"""
    simplecycles(g, ::SimpleCycleAlgorithm)

Find circuits (including self-loops) in graph `g` using a
specified `SimpleCycleAlgorithm`.
"""
function simple_cycles end

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



export HawickJames, Johnson
export cycle_basis, simple_cycles

end # module
