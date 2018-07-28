module Experimental

using LightGraphs
using LightGraphs.SimpleGraphs

export description,
    #isomorphism
    vf2, IsomorphismProblem, SubgraphIsomorphismProblem, InducedSubgraphIsomorphismProblem,
    has_iso, all_iso, count_iso,
    has_induced_subgraphiso, count_induced_subgraphiso, all_induced_subgraphiso,
    has_subgraphiso, count_subgraphiso, all_subgraphiso

description() = "This module contains experimental graph functions."

include("isomorphism.jl")

end
