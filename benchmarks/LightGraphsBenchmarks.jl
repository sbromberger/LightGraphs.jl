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
benchdatadir = joinpath(dirname(@__FILE__), "data")
paramsfile = joinpath(benchdatadir, "params.jld")

println("testdatadir = $testdatadir")
println("paramsfile = $paramsfile")

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
	  "core",
    "edgetype",
	# "centrality.jl",
    "max-flow",
    "connectivity",
    "traversals"
]

for m in MODULES
    include("$(m).jl")
end

function save_benchmarks(results, datadir=benchdatadir)
  ts = string(now())
  for m in MODULES
    d = joinpath(datadir, m)
    isdir(d) || mkdir(d)
    f = joinpath(d, "$(ts).jld")
    JLD.save(f, m, results[m])
  end
end

function _getlastresults(datadir=benchdatadir)
  files = Vector{Tuple{String, String}}()
  for m in MODULES
    d = joinpath(datadir, m)
    f = sort(readdir(d))[end]
    push!(files, (m, joinpath(d,f)))
  end
  return files
end

function load_benchmarks(files::Vector{Tuple{String, String}}=_getlastresults(), datadir=benchdatadir)
  b = BenchmarkGroup()
  for (m, f) in files
    println("loading module $m from file $f")
    b[m] = JLD.load(f, m)
  end
  return b
end

function load_benchmarks(dts::String, datadir=benchdatadir)
  fs = [joinpath(datadir, m, "$(dts).jld") for m in MODULES]
  files = collect(zip(MODULES, fs))
  return load_benchmarks(files, datadir)
end

function run_benchmarks()
  if isfile(paramsfile)
    loadparams!(SUITE, BenchmarkTools.load(paramsfile, "suite"), :evals, :samples)
  end
  run(SUITE, verbose=true)
end

function tune_and_save!(b::BenchmarkGroup=SUITE)
  tune!(b)
  BenchmarkTools.save(paramsfile, "suite", params(b))
end

end
