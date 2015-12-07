using Base.Test
using LightGraphs
import LightGraphs: nearbipartiteSBM, sample, StochasticBlockModel, graph, blockfractions, blockcounts
#using ArgParse
using PyPlot

function generate_nbp_sbm(numedges, sizes)
    density = 1
    #= print(STDERR, "Generating communites with sizes: $sizes\n") =#
    between = density * 0.90
    intra = density * -0.005
    noise = density * 0.00501
    sbm = nearbipartiteSBM(sizes,between, intra, noise)
    edgestream = @task sample(sbm)
    g = graph(edgestream, sizes, numedges)
    return sbm, g
end


numedges = 100
sizes = [ 10,10,10,10]

n = sum(sizes)
sbm, g = generate_nbp_sbm(numedges, sizes)
bc = blockcounts(sbm, g)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@test norm(ratios) < 0.25
#= println("Block counts:\n $bc") =#

sizes = [200,200, 100]
internaldeg = 15
externaldeg = 6
internalp = Float64[internaldeg/i for i in sizes]
externalp = externaldeg/sum(sizes)
numedges = internaldeg + externaldeg#+ sum(externaldeg.*sizes[2:end])
numedges *= floor(Int, sum(sizes)/2)
sbm = StochasticBlockModel(internalp, externalp, sizes)
edgestream = @task sample(sbm)
g = graph(edgestream, sizes, numedges)
@test ne(g) <= numedges
@test nv(g) == sum(sizes)
bc = blockcounts(sbm, g)
bp = blockfractions(sbm, g) ./ (sizes * sizes')
ratios = bp ./ (sbm.affinities ./ sum(sbm.affinities))
@test norm(ratios) < 0.25
#= println("Block counts:\n $bc") =#
# check that average degree is not too high 
# factor of two is cushion for random process
@test mean(degree(g)) < 4//2*numedges/sum(sizes)
# check that the internal degrees are higher than the external degrees
# 5//4 is cushion for random process.
@test all(sum(bc-diagm(diag(bc)), 1) .<= 5//4 .* diag(bc))
