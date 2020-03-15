module Experimental

using LightGraphs
using LightGraphs.SimpleGraphs

export description,
    #isomorphism
    VF2, vf2, IsomorphismProblem, SubgraphIsomorphismProblem, InducedSubgraphIsomorphismProblem,
    could_have_isomorph, has_isomorph, all_isomorph, count_isomorph,
    has_induced_subgraphisomorph, count_induced_subgraphisomorph, all_induced_subgraphisomorph,
    has_subgraphisomorph, count_subgraphisomorph, all_subgraphisomorph, dominator_tree,

    ShortestPaths
description() = "This module contains experimental graph functions."

include("isomorphism.jl")
include("dominator_tree.jl")
include("vf2.jl") # Julian implementation of VF2 algorithm
include("ShortestPaths/ShortestPaths.jl")

end
