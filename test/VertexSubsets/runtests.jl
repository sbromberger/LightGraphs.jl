using LightGraphs.VertexSubsets
using LightGraphs.Generators
const LGVS = LightGraphs.VertexSubsets
const LGGEN = LightGraphs.Generators
const vstestdir = dirname(@__FILE__)

vstests = [
  "degree_dom_set.jl",
  "degree_vertex_cover.jl",
  "minimal_dom_set.jl",
  "parallel-maximal_ind_set.jl",
  "parallel-minimal_dom_set.jl",
  "parallel-random_vertex_cover.jl",
  "random_vertex_cover.jl",
  "threaded-maximal_ind_set.jl",
  "threaded-minimal_dom_set.jl",
  "threaded-random_vertex_cover.jl",

]

@testset "LightGraphs.VertexSubsets" begin
    for t in vstests
        tp = joinpath(vstestdir, "$t")
        include(tp)
    end
end

