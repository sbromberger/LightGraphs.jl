module Coloring

using Base.Threads
using SimpleTraits
using Distributed
using Random: AbstractRNG, GLOBAL_RNG, shuffle, shuffle!
using DataStructures: Queue, enqueue!, dequeue!
using LightGraphs
using LightGraphs.Connectivity: connected_components, UnionMerge, DFSQ

include("bipartition.jl")
include("greedy_color.jl")
include("threaded-greedy_color.jl")

end # module
