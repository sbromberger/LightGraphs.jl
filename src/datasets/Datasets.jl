module Datasets

using ...LightGraphs
using MatrixDepot

# smallgraphs
export smallgraph,

# matrixdepot
MDGraph, MDDiGraph

include("smallgraphs.jl")
include("matrixdepot.jl")

end
