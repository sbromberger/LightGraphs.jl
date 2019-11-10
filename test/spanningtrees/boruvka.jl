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
    #cost_mst = 8.0

    max_vec_mst = Vector{Edge}([Edge(1, 4), Edge(2, 4), Edge(1, 3)])
    cost_max_vec_mst = sum(distmx[src(e),dst(e)] for e in max_vec_mst)
    #cost_max_vec_mst = 21.0

    for g in testgraphs(g4)
    # Testing Boruvka's algorithm
        @test @inferred(boruvka_mst(g, distmx)) == (vec_mst,cost_mst)

        @test @inferred(boruvka_mst(g, distmx, minimize=false)) == (max_vec_mst,cost_max_vec_mst)

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
    #weight_vec2 = 1.8099999999999998
    

    max_vec2 = Vector{Edge}([Edge(1, 7), Edge(2, 3), Edge(3, 7), Edge(4, 7), Edge(5, 7), Edge(5, 6), Edge(5, 8)])
    weight_max_vec2 = sum(distmx_sec[src(e),dst(e)] for e in max_vec2)
    #weight_max_vec2 = 3.5100000000000002

    for g in testgraphs(gx)
        @test @inferred(boruvka_mst(g, distmx_sec)) == (vec2,weight_vec2)
 
        @test @inferred(boruvka_mst(g, distmx_sec, minimize = false)) == (max_vec2,weight_max_vec2)
    end
    
end

