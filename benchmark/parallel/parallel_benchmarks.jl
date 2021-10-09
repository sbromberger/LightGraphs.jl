@show Threads.nthreads()

suite["parallel"] = BenchmarkGroup()

# include all benchmarks
include("egonets.jl")
