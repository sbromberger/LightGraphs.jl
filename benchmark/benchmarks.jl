using BenchmarkTools
using LightGraphs


DIGRAPHS = Dict{String,DiGraph}(
    "complete100"   => complete_digraph(100),
    "path500"       => path_digraph(500)
)

GRAPHS = Dict{String,Graph}(
    "complete100"   => complete_graph(100),
    "tutte"         => smallgraph(:tutte),
    "path500"       => path_graph(500)
)


suite = BenchmarkGroup()

# include all benchmarks
include("core.jl")
include("centrality.jl")
include("connectivity.jl")
include("edges.jl")
include("insertions.jl")
include("traversals.jl")

# include parallel benchmarks
include("parallel/parallel_benchmarks.jl")

tune!(suite);
results = run(suite, verbose = true, seconds = 10)
