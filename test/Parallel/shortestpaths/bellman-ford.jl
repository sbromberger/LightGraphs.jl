@testset "Parallel.Bellman Ford" begin
    g4 = path_digraph(5)

    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    for g in testdigraphs(g4)
        y = @inferred(shortest_paths(g, [2], d1, ThreadedBellmanFord()))
        z = @inferred(shortest_paths(g, [2], d2, ThreadedBellmanFord()))
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
        @test @inferred(paths(z))[2] == []
        @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
        @test @inferred(!Parallel.has_negative_edge_cycle(g, d1))


        y = @inferred(shortest_paths(g, [2], d1, ThreadedBellmanFord()))
        z = @inferred(shortest_paths(g, [2], d2, ThreadedBellmanFord()))
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
        @test @inferred(paths(z))[2] == []
        @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
        z = @inferred(shortest_paths(g, [2], ThreadedBellmanFord()))
        @test z.dists == [typemax(Int), 0, 1, 2, 3]
    end

    # Negative Cycle
    gx = complete_graph(3)
    for g in testgraphs(gx)
        d = [1 -3 1; -3 1 1; 1 1 1]
        @test_throws NegativeCycleError shortest_paths(g, [1], d, ThreadedBellmanFord())
        @test Parallel.has_negative_edge_cycle(g, d)

        d = [1 -1 1; -1 1 1; 1 1 1]
        @test_throws NegativeCycleError shortest_paths(g, [1], d, ThreadedBellmanFord())
        @test Parallel.has_negative_edge_cycle(g, d)
    end

    # Negative cycle of length 3 in graph of diameter 4
    gx = complete_graph(4)
    d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
    for g in testgraphs(gx)
        @test_throws NegativeCycleError shortest_paths(g, [1], d, ThreadedBellmanFord())
        @test Parallel.has_negative_edge_cycle(g, d)
    end
end
