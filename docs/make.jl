using Documenter
#include("../src/LightGraphs.jl")
using LightGraphs

# same for contributing and license
cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); force=true)
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); force=true)

makedocs(
    modules     = [LightGraphs],
    format      = Documenter.HTML(), 
    sitename    = "LightGraphs",
    doctest     = false,
    pages       = Any[
        "Getting Started"                   => "index.md",
        "Choosing A Graph Type"             => "graphtypes.md",
        "LightGraphs Types"                 => "types.md",
        "Accessing Properties"              => "basicproperties.md",
        "Making and Modifying Graphs"       => "generators.md",
        "Reading / Writing Graphs"          => "persistence.md",
        "Operators"                         => "operators.md",
        "Plotting Graphs"                   => "plotting.md",
        "Path and Traversal"                => "pathing.md",
        "Coloring"                          => "coloring.md",
        "Distance"                          => "distance.md",
        "Centrality Measures"               => "centrality.md",
        "Linear Algebra"                    => "linalg.md",
        "Matching"                          => "matching.md",
        "Community Structures"              => "community.md",
        "Degeneracy"                        => "degeneracy.md",
        "Integration with other packages"   => "integration.md",
        "Experimental Functionality"        => "experimental.md",
        "Parallel Algorithms"               => "parallel.md",
        "Contributing"                      => "contributing.md",
        "Developer Notes"                   => "developing.md",
        "License Information"               => "license.md",
        "Citing LightGraphs"                => "citing.md"
    ]
)

deploydocs(
    repo        = "github.com/JuliaGraphs/LightGraphs.jl.git",
    target      = "build",
)

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
