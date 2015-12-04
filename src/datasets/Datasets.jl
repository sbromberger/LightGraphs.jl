module Datasets

using ...LightGraphs
using Requires
try
    using MatrixDepot
    nothing
catch
end

# smallgraphs
export smallgraph,

# matrixdepot
MDGraph, MDDiGraph

include("smallgraphs.jl")
include("matrixdepot.jl")

end
