using LightGraphs
import LightGraphs: nearbipartiteSBM, sample, StochasticBlockModel, graph, blockfractions
#using ArgParse
using PyPlot

function main(filename, numedges, sizes)
    density = 1
    print(STDERR, "Generating communites with sizes: $sizes\n")
    between = density * 0.99
    intra = density * -0.005
    noise = density * 0.00501
    sbm = nearbipartiteSBM(sizes,between, intra, noise)
    edgestream = @task sample(sbm)
    g = graph(edgestream, sizes, numedges)
    println(g)
    open(filename, "w") do filep
        writegraphml(filep, g)
    end
    return sbm, g
end


println(STDERR, ARGS)
argc = length(ARGS)
progname = ARGS[1]
if argc < 1
    println(STDERR, "not enough arguments")
end

usagestr = "Usage: $progname outputfilename numedges size1 size2 ... sizeN\n"
if argc < 5
    println(STDERR, usagestr)
    exit(1)
end

filename = ARGS[2]
NUMEDGES = parse(Int, ARGS[3])
sizes = [ parse(Int, i) for i in ARGS[4:end] ]
n = sum(sizes)
sbm, g = main(filename, NUMEDGES, sizes)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@show norm(ratios)
#println("Block counts:\n $bc")
println("Block ratios:\n $ratios")
spy(adjacency_matrix(g), markersize=1)
title("Near Bipartite")
show()

internaldeg = 15
internalp = Float64[internaldeg/i for i in sizes]
externaldeg = 6
externalp = externaldeg/sum(sizes)
sbm = StochasticBlockModel(internalp, externalp, sizes)
edgestream = @task sample(sbm)
println(edgestream)
g = graph(edgestream, sizes, NUMEDGES)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@show norm(ratios)
println("Block counts:\n $ratios")
@show degree(g)
spy(adjacency_matrix(g), markersize=1)
title("SBM: \$$internaldeg\$,\$$externalp\$")
show()
