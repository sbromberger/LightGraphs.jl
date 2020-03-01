    @testset "AStar" begin
        g3 = path_graph(5)
        g4 = path_digraph(5)

        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
        for g in testgraphs(g3), dg in testdigraphs(g4)
            y = @inferred(shortest_paths(g, 1, 4, d1, AStar()))
            @test y == @inferred(shortest_paths(dg, 1, 4, d1, AStar())) ==
            @inferred(shortest_paths(g, 1, 4, d2, AStar()))
            @test paths(y) == [y.path]
            @test_throws ArgumentError paths(y, 2)
            @test dists(y) == [[y.dist]]
            @test_throws ArgumentError dists(y, 2)

            z = @inferred(shortest_paths(dg, 4, 1, AStar()))
            @test isempty(z.path)
            @test isempty(paths(z)[1])
            @test dists(z)[1] == [typemax(Int)]
        end

        # test for #1258
       
        g = complete_graph(4)
        w = float([1 1 1 4; 1 1 1 1; 1 1 1 1; 4 1 1 1])
        @test length(first(paths(shortest_paths(g, 1, 4, w, AStar())))) == 3
    end

