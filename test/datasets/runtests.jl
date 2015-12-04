tests = [
    "datasets/smallgraphs",
    "datasets/matrixdepot"
]


for t in tests
    tp = joinpath(testdir,"$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
