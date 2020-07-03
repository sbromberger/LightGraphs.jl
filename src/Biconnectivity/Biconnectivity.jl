module Biconnectivity

# Biconnectivity functions are NOT implemented using visitor functions to optimize performance
# Refer #1437 for comparison of benchmarks with and without using visitor functions
using LightGraphs
using LightGraphs.SimpleGraphsCore: SimpleEdge
using SimpleTraits

include("articulation.jl")
include("bridge.jl")
include("biconnect.jl")

end # module
