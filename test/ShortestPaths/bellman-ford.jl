@testset "ShortestPaths.BellmanFord" begin
    g4 = SimpleDiGraph(SGGEN.Path(5))

    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    @testset "$g" for g in testdigraphs(g4)
        y = @inferred(ShortestPaths.shortest_paths(g, 2, d1, ShortestPaths.BellmanFord()))
        z = @inferred(ShortestPaths.shortest_paths(g, 2, d2, ShortestPaths.BellmanFord()))
        @test ShortestPaths.distances(y) == ShortestPaths.distances(z) == [Inf, 0, 6, 17, 33]
        @test @inferred(ShortestPaths.paths(z))[2] == []
        @test @inferred(ShortestPaths.paths(z))[4] == ShortestPaths.paths(z, 4) == [2, 3, 4]
        @test @inferred(!ShortestPaths.has_negative_weight_cycle(g, ShortestPaths.BellmanFord()))
        @test @inferred(!ShortestPaths.has_negative_weight_cycle(g, d1, ShortestPaths.BellmanFord()))


        y = @inferred(ShortestPaths.shortest_paths(g, 2, d1, ShortestPaths.BellmanFord()))
        z = @inferred(ShortestPaths.shortest_paths(g, 2, d2, ShortestPaths.BellmanFord()))
        @test ShortestPaths.distances(y) == ShortestPaths.distances(z) == [Inf, 0, 6, 17, 33]
        @test @inferred(ShortestPaths.paths(z))[2] == []
        @test @inferred(ShortestPaths.paths(z))[4] == ShortestPaths.paths(z, 4) == [2, 3, 4]
        @test @inferred(!ShortestPaths.has_negative_weight_cycle(g, ShortestPaths.BellmanFord()))
        z = @inferred(ShortestPaths.shortest_paths(g, 2, ShortestPaths.BellmanFord()))
        @test ShortestPaths.distances(z) == [typemax(Int), 0, 1, 2, 3]
    end

    # Negative Cycle
    gx = SimpleGraph(SGGEN.Complete(3))
    @testset "$g" for g in testgraphs(gx)
        d = [1 -3 1; -3 1 1; 1 1 1]
        @test_throws LightGraphs.ShortestPaths.NegativeCycleError ShortestPaths.shortest_paths(g, 1, d, ShortestPaths.BellmanFord())
        @test ShortestPaths.has_negative_weight_cycle(g, d, ShortestPaths.BellmanFord())

        d = [1 -1 1; -1 1 1; 1 1 1]
        @test_throws LightGraphs.ShortestPaths.NegativeCycleError ShortestPaths.shortest_paths(g, 1, d, ShortestPaths.BellmanFord())
        @test ShortestPaths.has_negative_weight_cycle(g, d, ShortestPaths.BellmanFord())
        @test ShortestPaths.has_negative_weight_cycle(g, d)
    end

    # Negative cycle of length 3 in graph of diameter 4
    gx = SimpleGraph(SGGEN.Complete(4))
    d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
    @testset "$g" for g in testgraphs(gx)
        @test_throws LightGraphs.ShortestPaths.NegativeCycleError ShortestPaths.shortest_paths(g, 1, d, ShortestPaths.BellmanFord())
        @test ShortestPaths.has_negative_weight_cycle(g, d)
    end
end
