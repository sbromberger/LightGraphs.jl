@testset "Kruskal" begin
    g4 = CompleteGraph(4)

    distmx = [
      0  1  5  6
      1  0  4  10
      5  4  0  3
      6  10  3  0
    ]

    vec_mst = Vector{Edge}([Edge(1, 2), Edge(3, 4), Edge(2, 3)])
    for g in testgraphs(g4)
    # Testing Kruskal's algorithm
      mst = kruskal_mst(g, distmx)
      @test @inferred(mst) == vec_mst
    end
      #second test
      distmx_sec = [
                    0   0   0.26    0   0.38    0   0.58    0.16
                    0   0   0.36    0.29    0   0.32    0   0.19
                    0.26    0.36    0   0.17    0   0   0.4 0.34
                    0   0.29    0.17    0   0   0   0.52    0
                    0.38    0   0   0   0   0.35    0.93    0.37
                    0   0.32    0   0   0.35    0   0   0.28
                    0.58    0   0.4 0.52    0.93    0   0   0
                    0.16    0.19    0.34    0   0.37    0.28    0   0
                    ]

    gx = Graph(distmx_sec)
    vec2 = Vector{Edge}([Edge(1, 8),Edge(3, 4),Edge(2, 8),Edge(1, 3),Edge(6, 8),Edge(5, 6),Edge(3, 7)])
    for g in testgraphs(gx)
      mst2 = kruskal_mst(g, distmx_sec)
      @test @inferred(mst2) == vec2
    end
end
