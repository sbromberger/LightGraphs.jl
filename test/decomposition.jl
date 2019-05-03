@testset "Decomposition" begin
        # graph from https://en.wikipedia.org/wiki/Ear_decomposition
        elist = [(1,2),(1,5),(1,8),(2,3),(2,7),(3,4),(4,5),(4,6), (6, 7), (7, 8)];
        g1 = SimpleGraph(8)
        for e in elist
            add_edge!(g1, e[1], e[2])
        end

        ear_d1 = @inferred(ear_decomposition(g1, 1))
        expected_results = [[1, 5, 4, 3, 2, 1], [1, 8, 7, 6, 4], [2, 7]]
        @test ear_d1 == expected_results

        # test for path graph
        g2 = PathGraph(5)
        ear_d2 = @inferred(ear_decomposition(g2, 1))
        @test ear_d2 == []

        # test for cycle graph
        g3 = PathGraph(5)
        add_edge!(g3, 1, 5)
        ear_d3 = @inferred(ear_decomposition(g3, 1))
        expected_results = [[1, 5, 4, 3, 2, 1]]
        @test ear_d3 == expected_results

        # test for disconnected graph
        elist = [(1,2),(2,3),(2,4),(3,4),(4,1), (5, 6), (5, 7), (5, 8), (6, 7), (7, 8)]
        g4 = SimpleGraph(8)
        for e in elist
            add_edge!(g4, e[1], e[2])
        end
        ear_d4 = @inferred(ear_decomposition(g4, 5))
        expected_results = [[5, 7, 6, 5], [5, 8, 7], [1, 4, 3, 2, 1],[2, 4]]
        @test ear_d4 == expected_results

        # test for null graph
        g5 = SimpleGraph(2)
        ear_d5 = @inferred(ear_decomposition(g5))
        expected_results = []
        @test ear_d5 == expected_results

        # test for a graph with single edge
        g5 = SimpleGraph(2)
        add_edge!(g5, (1, 2))
        ear_d6 = @inferred(ear_decomposition(g5))
        expected_results = []
        @test ear_d6 == expected_results

        # test for a graph with loops, i.e all loops are ignored
        add_edge!(g5, (1, 1))
        ear_d7 = @inferred(ear_decomposition(g5))
        expected_results = []
        @test ear_d7 == expected_results

        # test for a graph of type Int8
        g6 = SimpleGraph(Int8(8))
        for e in elist
            add_edge!(g6, Int8(e[1]), Int8(e[2]))
        end
        ear_d8 = @inferred(ear_decomposition(g6, 2))
        expected_results =  [Int8[2, 3, 4, 1, 2], Int8[2, 4], Int8[5, 7, 6, 5], Int8[5, 8, 7]]
        @test ear_d8 == expected_results
end
