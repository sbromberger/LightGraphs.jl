module Experimental

using LightGraphs
using LightGraphs.SimpleGraphs

export description,
    #isomorphism
    VF2, vf2, IsomorphismProblem, SubgraphIsomorphismProblem, InducedSubgraphIsomorphismProblem,
    could_have_isomorph, has_isomorph, all_isomorph, count_isomorph,
    has_induced_subgraphisomorph, count_induced_subgraphisomorph, all_induced_subgraphisomorph,
    has_subgraphisomorph, count_subgraphisomorph, all_subgraphisomorph,

    # aggregation
    AbstractGraphResults, ShortestPathResults, 
    AbstractGraphAlgorith, ShortestPathAlgorithm,
    DijkstraShortestPathResults, DijkstraShortestPathAlgorithm,
    BellmanFordShortestPathResults, BellmanFordShortestPathAlgorithm,
    shortest_paths
    #
description() = "This module contains experimental graph functions."

include("isomorphism.jl")
include("vf2.jl") # Julian implementation of VF2 algorithm
include("aggregation.jl") # new interface

end
