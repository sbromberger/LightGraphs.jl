using LightGraphs
import LightGraphs: nearbipartiteSBM, sample, StochasticBlockModel, graph, blockfractions, blockcounts
#using ArgParse
using PyPlot

function main(numedges, sizes)
    density = 1
    print(STDERR, "Generating communites with sizes: $sizes\n")
    between = density * 0.90
    intra = density * -0.005
    noise = density * 0.00501
    sbm = nearbipartiteSBM(sizes,between, intra, noise)
    edgestream = @task sample(sbm)
    g = graph(edgestream, sizes, numedges)
    println(g)
    return sbm, g
end


NUMEDGES = 100
sizes = [ 10,10,10,10]

n = sum(sizes)
sbm, g = main(NUMEDGES, sizes)
bc = blockcounts(sbm, g)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@show norm(ratios)
println("Block counts:\n $bc")
#= println("Block ratios:\n $ratios") =#
spy(adjacency_matrix(g), markersize=1)
title("Near Bipartite")
show()
figure()

sizes = [200,200, 100]
internaldeg = 15
externaldeg = 6
internalp = Float64[internaldeg/i for i in sizes]
externalp = externaldeg/sum(sizes)
NUMEDGES = internaldeg + externaldeg#+ sum(externaldeg.*sizes[2:end])
NUMEDGES *= floor(Int, sum(sizes)/2)
sbm = StochasticBlockModel(internalp, externalp, sizes)
edgestream = @task sample(sbm)
println(edgestream)
g = graph(edgestream, sizes, NUMEDGES)
bc = blockcounts(sbm, g)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@show norm(ratios)
println("Block counts:\n $bc")
@show diag(bc)
@show sum(bc-diagm(diag(bc)), 1)
@show degree(g)
spy(adjacency_matrix(g), markersize=1)
title("SBM: \$$internaldeg\$,\$$externaldeg\$")
show()
@assert all(sum(bc-diagm(diag(bc)), 1) .<= diag(bc))
