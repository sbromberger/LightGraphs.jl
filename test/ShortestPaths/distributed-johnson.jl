@testset "Distributed Johnson" begin
    g3 = path_graph(5)
    d = Symmetric([0 1 2 3 4; 1 0 6 7 8; 2 6 0 11 12; 3 7 11 0 16; 4 8 12 16 0])
    d2 = ones(nv(g), nv(g))
    for g in testgraphs(g3)
        @test @inferred(ShortestPaths.shortest_paths(g, ShortestPaths.DistributedJohnson)) == ShortestPaths.shortest_paths(g, d, ShortestPaths.DistributedJohnson())
        z = @inferred(ShortestPaths.shortest_paths(g, d, ShortestPaths.DistributedJohnson()))
        @test Traversals.distances(z)[3, :][:] == [7, 6, 0, 11, 27]
        @test Traversals.parents(z)[3, :][:] == [2, 3, 0, 3, 4]
        @test @inferred(ShortestPaths.paths(z))[2][2] == []
        @test @inferred(ShortestPaths.paths(z))[2][4] == ShortestPaths.paths(z, 2)[4] == ShortestPaths.paths(z, 2, 4) == [2, 3, 4]
    end

    g4 = path_digraph(4)
    for g in testdigraphs(g4)
        z = @inferred(ShortestPaths.shortest_paths(g, ShortestPaths.DistributedJohnson()))
        @test length(ShortestPaths.paths(z, 4, 3)) == 0
        @test length(ShortestPaths.paths(z, 4, 1)) == 0
        @test length(ShortestPaths.paths(z, 2, 3)) == 2
    end 

    g5 = DiGraph([1 1 1 0 1; 0 1 0 1 1; 0 1 1 0 0; 1 0 1 1 0; 0 0 0 1 1])
    d = [0 3 8 0 -4; 0 0 0 1 7; 0 4 0 0 0; 2 0 -5 0 0; 0 0 0 6 0]
    for g in testdigraphs(g5)
        z = @inferred(ShortestPaths.shortest_paths(g, d, ShortestPaths.DistributedJohnson()))
        @test z.Traversals.dists == [0 1 -3 2 -4; 3 0 -4 1 -1; 7 4 0 5 3; 2 -1 -5 0 -2; 8 5 1 6 0]
    end 
end
