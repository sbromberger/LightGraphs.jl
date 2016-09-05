using Documenter
# include("../src/LightGraphs.jl")
using LightGraphs

# index is equal to the README for the time being
cp(normpath(@__FILE__, "../../README.md"), normpath(@__FILE__, "../src/index.md"); remove_destination=true)

makedocs(modules=[LightGraphs], doctest = false)


deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/JuliaGraphs/LightGraphs.jl.git"
#    julia  = "release"
)

rm(normpath(@__FILE__, "../src/index.md"))
