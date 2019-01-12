@testset "Prim" begin
    g4 = CompleteGraph(4)

    distmx = [
      0  1  5  6
      1  0  4  10
      5  4  0  3
      6  10  3  0
    ]

    vec_mst = Vector{Edge}([Edge(1, 2), Edge(2, 3), Edge(3, 4)])
    for g in testgraphs(g4)
        # Testing Prim's algorithm
        mst = @inferred(prim_mst(g, distmx))
        @test mst == vec_mst
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

    vec2 = Vector{Edge}([Edge(8, 2), Edge(1, 3), Edge(3, 4), Edge(6, 5), Edge(8, 6), Edge(3, 7), Edge(1, 8)])
    gx = SimpleGraph(distmx_sec)
    for g in testgraphs(gx)
        mst2 = @inferred(prim_mst(g, distmx_sec))
        @test mst2 == vec2
    end

    
    # Third test: Example from
    #   https://en.wikipedia.org/wiki/Kruskal%27s_algorithm#Example
    # Adapted from networkx
    #   https://github.com/networkx/networkx/blob/master/networkx/algorithms/tree/tests/test_mst.py
    edges_w = [(0, 1, 7), (0, 3, 5), (1, 2, 8), (1, 3, 9), (1, 4, 7),
               (2, 4, 5), (3, 4, 15), (3, 5, 6), (4, 5, 8), (4, 6, 9),
               (5, 6, 11)]
    n = 7

    if false    # verify the example, visually
        for e in edges_w
            println("$('A' + e[1]) -- $('A' + e[2]): $(e[3])")
        end
    end

    gx = LightGraphs.SimpleGraph([Edge(e[1]+1, e[2]+1) for e in edges_w])

    @test nv(gx) == n
    @test ne(gx) == length(edges_w)

    distmx3 = zeros(Float64, n, n)
    for e in edges_w
        distmx3[e[1]+1, e[2]+1] = e[3]
        distmx3[e[2]+1, e[1]+1] = e[3]
    end
    mst3 = @inferred(prim_mst(gx, distmx3))

    expected3 = [Edge(e[1]+1, e[2]+1)
                 for e in [(0, 1, 7),
                           (0, 3, 5),
                           (1, 4, 7),
                           (2, 4, 5),
                           (3, 5, 6),
                           (4, 6, 9)]]

    """
    The cost of the edge selection `es` given the distance matrix `distmx`
    """
    edge_costs(es, distmx) =
        sum(distmx[e.src, e.dst] for e in es)

    @test edge_costs(mst3, distmx3) == edge_costs(expected3, distmx3)
end
