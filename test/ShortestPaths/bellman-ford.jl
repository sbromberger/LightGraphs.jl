    @testset "BellmanFord" begin
	    g4 = path_digraph(5)

	    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
	    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
	    for g in testdigraphs(g4)
            y = @inferred(shortest_paths(g, 2, d1, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, d2, BellmanFord()))
            @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
            @test @inferred(paths(z))[2] == []
            @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
            @test @inferred(!has_negative_weight_cycle(g, BellmanFord()))
            @test @inferred(!has_negative_weight_cycle(g, d1, BellmanFord()))


            y = @inferred(shortest_paths(g, 2, d1, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, d2, BellmanFord()))
            @test dists(y) == dists(z) == [Inf, 0, 6, 17, 33]
            @test @inferred(paths(z))[2] == []
            @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
            @test @inferred(!has_negative_weight_cycle(g, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, BellmanFord()))
            @test dists(z) == [typemax(Int), 0, 1, 2, 3]
        end

        # Negative Cycle
        gx = complete_graph(3)
        for g in testgraphs(gx)
            d = [1 -3 1; -3 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d, BellmanFord())

            d = [1 -1 1; -1 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d, BellmanFord())
            @test has_negative_weight_cycle(g, d)
        end

        # Negative cycle of length 3 in graph of diameter 4
        gx = complete_graph(4)
        d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
        for g in testgraphs(gx)
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d)
        end
    end
