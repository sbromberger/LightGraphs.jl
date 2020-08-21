using LightGraphs.VertexSubsets
using LightGraphs.Generators
const LGVS = LightGraphs.VertexSubsets
const LGGEN = LightGraphs.Generators
const vstestdir = dirname(@__FILE__)

vstests = [
  "degree_dom_set.jl",
  "degree_vertex_cover.jl",
  "random_dom_set.jl",
  "random_vertex_cover.jl",
  "distributed-random_ind_set.jl",
  "distributed-random_dom_set.jl",
  "distributed-random_vertex_cover.jl",
  "threaded-random_ind_set.jl",
  "threaded-random_dom_set.jl",
  "threaded-random_vertex_cover.jl",
  "luby_maximal_ind_set.jl"
]

@testset "LightGraphs.VertexSubsets" begin
    for t in vstests
        tp = joinpath(vstestdir, "$t")
        include(tp)
    end
end

