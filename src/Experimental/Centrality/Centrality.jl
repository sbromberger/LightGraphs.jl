module Centrality
using LightGraphs

# TODO: figure out how we keep environmental params.
# struct LGEnvironment
#     threaded::Bool
#     parallel::Bool
#     LGEnvironment() = new(false, false)
# end

abstract type AbstractGraphAlgorithm end

"""
    CentralityAlgorithm <: AbstractGraphAlgorithm
Concrete subtypes of `CentralityAlgorithm` are used to specify
the type of centrality calculation used by [`centrality`](@ref).
See [`Betweenness`](@ref), [`Closeness`](@ref), [`Degree`](@ref),
[`Eigenvector`](@ref), [`Katz`](@ref), [`PageRank`](@ref),
[`Radiality`](@ref), and [`Stress`](@ref) for specific requirements and
usage details.
"""
abstract type CentralityAlgorithm <: AbstractGraphAlgorithm end

include("betweenness.jl")
include("closeness.jl")
include("degree.jl")
include("eigenvector.jl")
include("katz.jl")
include("pagerank.jl")
include("radiality.jl")
include("stress.jl")


################################
# Centrality via algorithm #
################################
"""
    centrality(g, alg)
    centrality(g, α, n, ϵ)
    centrality(g, α)
    centrality(g)
Return a vector representing the centrality calculated for each node in `g`.
See `CentralityAlgorithm` for more details on the algorithm specifications.
### Examples
```
g = star_graph(3)
s1 = centrality(g)                   # `alg` defaults to `Betweenness`
s2 = centrality(g, 0.3)              # `alg` defaults to `Katz`
s3 = centrality(g, 0.3, 100, 1.0e-6) # `alg` defaults to `PageRank`
s4 = centrality(g, Closeness())
s5 = centrality(g, Radiality())
```
"""

export CentralityAlgorithm
export Betweenness, Closeness, Degree, Eigenvector, Katz, PageRank, Radiality, Stress

end  # module
