using Test
using DataStructures
using LightGraphs
using SimpleTraits

testgraphs(g) = is_directed(g) ? [g, DiGraph{UInt8}(g), DiGraph{Int16}(g)] : [g, Graph{UInt8}(g), Graph{Int16}(g)] 
testgraphs(gs...) = vcat((testgraphs(g) for g in gs)...)
testdigraphs = testgraphs
#above we have some functions and libs I need to run this tests
@testset "Boruvka" begin

g4 = complete_graph(4)

distmx = [
    0  1  5  6
    1  0  4  10
    5  4  0  3
    6  10  3  0
]

vec_mst = Vector{Edge}([Edge(1, 2), Edge(3, 4), Edge(2, 3)])
cost_mst = sum(distmx[src(e),dst(e)] for e in vec_mst)

max_vec_mst = Vector{Edge}([Edge(1, 4), Edge(2, 4), Edge(1, 3)])
cost_max_vec_mst = sum(distmx[src(e),dst(e)] for e in max_vec_mst)

for g in testgraphs(g4)
# Testing Boruvka's algorithm
    res1 = boruvka_mst(g,distmx)
    g1t = SimpleGraph(res1.mst)
    @test res1.weight == cost_mst
    # acyclic graphs have n - c edges
    @test nv(g1t) - length(connected_components(g1t)) == ne(g1t)
    @test nv(g1t) == nv(g)

    res2 = boruvka_mst(g,distmx,minimize=false)
    g2t = SimpleGraph(res2.mst)
    @test res2.weight == cost_max_vec_mst
    @test nv(g2t) - length(connected_components(g2t)) == ne(g2t)
    @test nv(g2t) == nv(g)

end
#second test
distmx_sec = [
    0       0       0.26    0       0.38    0       0.58    0.16
    0       0       0.36    0.29    0       0.32    0       0.19
    0.26    0.36    0       0.17    0       0       0.4     0.34
    0       0.29    0.17    0       0       0       0.52    0
    0.38    0       0       0       0       0.35    0.93    0.37
    0       0.32    0       0       0.35    0       0       0.28
    0.58    0       0.4     0.52    0.93    0       0       0
    0.16    0.19    0.34    0       0.37    0.28    0       0
]

gx = SimpleGraph(distmx_sec)

vec2 = Vector{Edge}([Edge(1, 8), Edge(2, 8), Edge(3, 4), Edge(5, 6), Edge(6, 8), Edge(3, 7), Edge(1, 3)])
weight_vec2 = sum(distmx_sec[src(e),dst(e)] for e in vec2)

max_vec2 = Vector{Edge}([Edge(1, 7), Edge(2, 3), Edge(3, 7), Edge(4, 7), Edge(5, 7), Edge(5, 6), Edge(5, 8)])
weight_max_vec2 = sum(distmx_sec[src(e),dst(e)] for e in max_vec2)

for g in testgraphs(gx)

    res3 = boruvka_mst(g, distmx_sec)
    g3t = SimpleGraph(res3.mst)
    @test res3.weight == weight_vec2
    @test nv(g3t) - length(connected_components(g3t)) == ne(g3t)
    @test nv(g3t) == nv(gx)

    res4 = boruvka_mst(g, distmx_sec,minimize = false)
    g4t = SimpleGraph(res4.mst)
    @test res4.weight == weight_max_vec2
    @test nv(g4t) - length(connected_components(g4t)) == ne(g4t)
    @test nv(g4t) == nv(gx)

end

#third test with two components

distmx_third = [
    0       0       0.26    0       0.38    0       0.58    0.16        0       0       0       0
    0       0       0.36    0.29    0       0.32    0       0.19        0       0       0       0
    0.26    0.36    0       0.17    0       0       0.4     0.34        0       0       0       0
    0       0.29    0.17    0       0       0       0.52    0           0       0       0       0
    0.38    0       0       0       0       0.35    0.93    0.37        0       0       0       0
    0       0.32    0       0       0.35    0       0       0.28        0       0       0       0  
    0.58    0       0.4     0.52    0.93    0       0       0           0       0       0       0       
    0.16    0.19    0.34    0       0.37    0.28    0       0           0       0       0       0
    0       0       0       0       0       0       0       0           0       1       5       6
    0       0       0       0       0       0       0       0           1       0       4       10
    0       0       0       0       0       0       0       0           5       4       0       3
    0       0       0       0       0       0       0       0           6       10      3       0       
]

gd = SimpleGraph(distmx_third)

vec3 = Vector{Edge}([Edge(1, 8), Edge(2, 8), Edge(3, 4), 
                    Edge(5, 6), Edge(6, 8), Edge(3, 7), 
                    Edge(9, 10), Edge(11,12),
                    Edge(1, 3), Edge(10,11)])
weight_vec3 = sum(distmx_third[src(e),dst(e)] for e in vec3)

max_vec3 = Vector{Edge}([Edge(1, 7), Edge(2, 3), Edge(3, 7),
                        Edge(4, 7), Edge(5, 7), Edge(5, 6), 
                        Edge(5, 8), Edge(9,12), Edge(10,12), Edge(9,11)])
weight_max_vec3 = sum(distmx_third[src(e),dst(e)] for e in max_vec3)


for g in testgraphs(gd)

    res5 = boruvka_mst(g, distmx_third)
    g5t = SimpleGraph(res5.mst)
    @test res5.weight == weight_vec3
    @test nv(g5t) - length(connected_components(g5t)) == ne(g5t)
    @test nv(g5t) == nv(gd)

    res6 = boruvka_mst(g, distmx_third,minimize = false)
    g6t = SimpleGraph(res6.mst)
    @test res6.weight == weight_max_vec3
    @test nv(g6t) - length(connected_components(g6t)) == ne(g6t)
    @test nv(g6t) == nv(gd)

end

end
