using Base.Test
using LightGraphs
assorts_path = Float64[]
for i in 3:20
    g = PathGraph(i)
    r = assortativity_degree(g)
    if i > 4
        @test r > assorts_path[end]
    end
    push!(assorts_path, r)
end
println(assorts_path)

n = 10
@show assortativity_degree(CompleteGraph(n))

g = PathGraph(20)
cat = outdegree(g)
@show r = assortativity(g, cat)
degassort = assortativity_degree(g)
@test_approx_eq r degassort
rprime = assortativity(g, cat, indegree(g))
@test_approx_eq r rprime 

# Functions that still need tests
#= assortativity_coefficient(g::Graph, sj, sk, sjs, sks, nue) =#
#= assortativity_coefficient(g::DiGraph, sj, sk, sjs, sks, nue) =#

#= local_assortativity_degree(g::Graph) =#
#= local_assortativity_degree(g::DiGraph) =#
#= nominal_assortativity_coefficient(g::Digraph, sumaibi, sumeii) =#
#= nominal_assortativity_coefficient(g::Graph, sumaibi, sumeii) =#
#= assortativity_nominal(g,cat) =#
