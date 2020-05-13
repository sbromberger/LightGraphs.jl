module Structure

using LightGraphs
using LightGraphs.SimpleGraphsCore
using DataStructures: PriorityQueue, enqueue!, dequeue!, peek

# export description,
#     #isomorphism
#     VF2, vf2, IsomorphismProblem, SubgraphIsomorphismProblem, InducedSubgraphIsomorphismProblem,
#     could_have_isomorph, has_isomorph, all_isomorph, count_isomorph,
#     has_induced_subgraphisomorph, count_induced_subgraphisomorph, all_induced_subgraphisomorph,
#     has_subgraphisomorph, count_subgraphisomorph, all_subgraphisomorph,

include("edit_distance.jl")
include("isomorphism.jl")
include("vf2.jl") # Julian implementation of VF2 algorithm

end
