@testset "Threaded BFS" begin

    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)

    @testset "$g" for g in testdigraphs(g5)
        # ThreadedBFS parents may differ from BFS
        @test @inferred(ShortestPaths.shortest_paths(g, 1, ShortestPaths.ThreadedBFS())).dists == ShortestPaths.shortest_paths(g, 1, ShortestPaths.BFS()).dists
        @test @inferred(ShortestPaths.shortest_paths(g, [1, 3], ShortestPaths.ThreadedBFS())).dists == ShortestPaths.shortest_paths(g, [1, 3], ShortestPaths.BFS()).dists
    end

    g6 = SimpleGraph(SGGEN.House())

    @testset "$g" for g in testgraphs(g6)
        # ThreadedBFS parents may differ from BFS
        @test @inferred(ShortestPaths.shortest_paths(g, 2, ShortestPaths.ThreadedBFS())).dists == ShortestPaths.shortest_paths(g, 2, ShortestPaths.BFS()).dists
        @test @inferred(ShortestPaths.shortest_paths(g, [1, 2], ShortestPaths.ThreadedBFS())).dists == ShortestPaths.shortest_paths(g, [1, 2], ShortestPaths.BFS()).dists
    end
end
