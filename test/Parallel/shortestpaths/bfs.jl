@testset "Parallel.BFS" begin
    
    g5 = SimpleDiGraph(4)
    add_edge!(g5, 1, 2); add_edge!(g5, 2, 3); add_edge!(g5, 1, 3); add_edge!(g5, 3, 4)
    
    for g in testdigraphs(g5)
        @test @inferred(Parallel.shortest_paths(g, 1, ThreadedBFS()))  == shortest_paths(g, 1, ShortestPaths.BFS())
        @test @inferred(Parallel.shortest_paths(g, [1, 3]), ThreadedBFS())  == shortest_paths(g, [1, 3], ShortestPaths.BFS())
    end

    g6 = smallgraph(:house)

    for g in testgraphs(g6)
        @test @inferred(Parallel.shortest_paths(g, 2), ThreadedBFS())  == shortest_paths(g, 2, ShortestPaths.BFS())
        @test @inferred(Parallel.shortest_paths(g, [1, 2]), ThreadedBFS()) == shortest_paths(g, [1, 2], ShortestPaths.BFS())
    end
end
