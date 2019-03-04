@testset "D'Esopo-Pape" begin
    g4 = PathDiGraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

    for g in testdigraphs(g4)
        y = @inferred(desopo_pape_shortest_paths(g, 2, d1))
        z = @inferred(desopo_pape_shortest_paths(g, 2, d2))

        @test y.parents == z.parents == [0, 0, 2, 3, 4]
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
    end
    
    gx = PathGraph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100
    for g in testgraphs(gx)
        z = @inferred(desopo_pape_shortest_paths(g, 1, d))
        @test z.dists == [0, 1, 3, 2, 3]
        @test z.parents == [0, 1, 4, 2, 4]
    end
    
    m = [0 2 2 0 0; 2 0 0 0 3; 2 0 0 1 2;0 0 1 0 1;0 3 2 1 0]
    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 2, 5)
    add_edge!(G, 3, 5)
    add_edge!(G, 3, 4)
    add_edge!(G, 4, 5)
    
    for g in testgraphs(G)
        y = @inferred(desopo_pape_shortest_paths(g, 1, m))
        @test z.parents == [0, 1, 1, 3, 3]
        @test z.dists == [0, 2, 2, 3, 4]
    end
end