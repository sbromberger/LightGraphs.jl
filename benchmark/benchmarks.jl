using PkgBenchmark
using LightGraphs


testdatadir = joinpath(dirname(@__FILE__), "..", "test", "testdata")
benchdatadir = joinpath(dirname(@__FILE__), "data")
paramsfile = joinpath(benchdatadir, "params.jld")

println("testdatadir = $testdatadir")
println("paramsfile = $paramsfile")

dg1fn = joinpath(testdatadir, "graph-5k-50k.jgz")

DIGRAPHS = Dict{String,DiGraph}(
    "complete100"  => complete_digraph(100),
    "5000-50000"   => LightGraphs.load(dg1fn)["graph-5000-50000"],
    "path500"      => path_digraph(500),
)

GRAPHS = Dict{String,Graph}(
    "complete100"  => complete_graph(100),
    "tutte"        => smallgraph(:tutte),
    "path500"      => path_graph(500),
    "5000-49947"   => SimpleGraph(DIGRAPHS["5000-50000"]),
)


@benchgroup "LightGraphsBenchmarks" begin
    include("core.jl")
    include("parallel/egonets.jl")
    include("insertions.jl")
    include("edges.jl")
    include("centrality.jl")
    include("connectivity.jl")
    include("traversals.jl")
end
