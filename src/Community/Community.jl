module Community

using LightGraphs
using SimpleTraits
using LightGraphs: getRNG


include("clique_percolation.jl")
include("cliques.jl")
include("clustering.jl")
include("core-periphery.jl")
include("label_propagation.jl")
include("modularity.jl")

export clique_percolation
export maximal_cliques
export local_clustering_coefficient, local_clustering, global_clustering_coefficient, triangles
export core_periphery_deg
export label_propagation
export modularity

end #module
