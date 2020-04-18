module Generators

using LinearAlgebra: rmul!
using Random: AbstractRNG, GLOBAL_RNG
using LightGraphs
using LightGraphs: is_graphical

abstract type GraphGenerator end

include("staticgenerators.jl")
include("randomgenerators.jl")
include("smallgenerators.jl")
include("euclideangenerators.jl")

export GraphGenerator, RandomGenerator, SmallGraph, StaticGenerator

end # module
