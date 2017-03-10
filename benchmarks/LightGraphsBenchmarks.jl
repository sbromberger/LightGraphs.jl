module LightGraphsBenchmarks

using BenchmarkTools
using JLD
using Compat
using LightGraphs

import Compat: UTF8String, view

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
BenchmarkTools.DEFAULT_PARAMETERS.samples = 10000
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 0.15
BenchmarkTools.DEFAULT_PARAMETERS.memory_tolerance = 0.01

const PARAMS_PATH = joinpath(dirname(@__FILE__), "params.jld")
const SUITE = BenchmarkGroup()

testdatadir = joinpath(dirname(@__FILE__), "..","test","testdata")
println("testdatadir = $testdatadir")

dg1fn = joinpath(testdatadir, "graph-5k-50k.jgz")

DIGRAPHS = Dict{String, DiGraph}(
    "complete100"   => CompleteDiGraph(100),
    "5000-50000"    => LightGraphs.load(dg1fn)["graph-5000-50000"],
    "path500"       => PathDiGraph(500)
)

GRAPHS = Dict{String, Graph}(
    "complete100"   => CompleteGraph(100),
    "tutte"         => smallgraph(:tutte),
    "path500"       => PathGraph(500),
    "5000-49947"    => Graph(DIGRAPHS["5000-50000"])
)

MODULES = [
	  "core.jl",
    "edgetype.jl",
	# "centrality.jl",
    "max-flow.jl",
    "connectivity.jl",
    "traversals.jl"
]

for m in MODULES
    include("$m")
end

run_benchmarks() = run(SUITE, verbose=true)

run_benchmarks()
end

