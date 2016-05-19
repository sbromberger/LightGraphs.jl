using Documenter

using GraphMatrices
using LightGraphs
using LightGraphs.Datasets

cp(normpath(@__FILE__, "../../README.md"), normpath(@__FILE__, "../src/index.md");remove_destination=true)
makedocs()
rm(normpath(@__FILE__, "../src/index.md"))
