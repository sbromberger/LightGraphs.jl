using Documenter
include("../src/LightGraphs.jl")
using LightGraphs

# same for contributing and license
cp(normpath(@__FILE__, "../../CONTRIBUTING.md"), normpath(@__FILE__, "../src/contributing.md"); remove_destination=true)
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); remove_destination=true)

makedocs(
    modules     = [LightGraphs],
    format      = :html,
    sitename    = "LightGraphs",
    doctest     = false,
    pages       = Any[
        "Getting Started"                   => "index.md",
        "LightGraph Types"                  => "types.md",
        "Accessing Properties"              => "basicproperties.md",
        "Making and Modifying Graphs"       => "generators.md",
        "Reading / Writing Graphs"          => "persistence.md",
        "Operators"                         => "operators.md",
        "Path and Traversal"                => "pathing.md",
        "Distance"                          => "distance.md",
        "Centrality Measures"               => "centrality.md",
        "Linear Algebra"                    => "linalg.md",
        "Matching"                          => "matching.md",
        "Community Structures"              => "community.md",
        "Degeneracy"                        => "degeneracy.md",
        "Flow and Cut"                      => "flowcut.md",
        "Integration with other packages"   => "integration.md",
        "Contributing"                      => "contributing.md",
        "License Information"               => "license.md"
    ]
)

deploydocs(
    deps        = nothing,
    make        = nothing,
    repo        = "github.com/JuliaGraphs/LightGraphs.jl.git",
    target      = "build",
    julia       = "0.6",
    osname      = "linux"
)

rm(normpath(@__FILE__, "../src/contributing.md"))
rm(normpath(@__FILE__, "../src/license.md"))
