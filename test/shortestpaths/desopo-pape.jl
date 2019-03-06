@testset "D'Esopo-Pape" begin
    @testset "Generic tests for graphs" begin
        g4 = PathDiGraph(5)
        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

        for g in testdigraphs(g4)
            y = @inferred(desopo_pape_shortest_paths(g, 2, d1))
            z = @inferred(desopo_pape_shortest_paths(g, 2, d2))

            @test y.parents == z.parents == [0, 0, 2, 3, 4]
            @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
        end
        
        @testset "Graph with cycle" begin
            gx = PathGraph(5)
            add_edge!(gx, 2, 4)
            d = ones(Int, 5, 5)
            d[2, 3] = 100
            for g in testgraphs(gx)
                z = @inferred(desopo_pape_shortest_paths(g, 1, d))
                @test z.dists == [0, 1, 3, 2, 3]
                @test z.parents == [0, 1, 4, 2, 4]
            end
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
    
    @testset "Graph with self loop" begin
        G = SimpleGraph(5)
        add_edge!(G, 2, 2)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 3, 3)
        add_edge!(G, 1, 5)
        add_edge!(G, 2, 4)
        add_edge!(G, 4, 5)
        m = [0 10 2 0 15; 10 9 0 1 0; 2 0 1 0 0; 0 1 0 0 2; 15 0 0 2 0]
        for g in testgraphs(G)
            z = @inferred(desopo_pape_shortest_paths(g, 1 , m))
            y = @inferred(dijkstra_shortest_paths(g, 1, m))
            @test isapprox(z.dists, y.dists)
        end
    end
    
    @testset "Disconnected graph" begin
        G = SimpleGraph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 4, 5)
        inf = typemax(eltype(G))
        for g in testgraphs(G)
            z = @inferred(desopo_pape_shortest_paths(g, 1))
            @test z.dists == [0, 1, 1, inf, inf]
            @test z.parents == [0, 1, 1, 0, 0]
        end
    end
    
    @testset "Empty graph" begin
        G = SimpleGraph(3)
        inf = typemax(eltype(G))
        for g in testgraphs(G)
            z = @inferred(desopo_pape_shortest_paths(g, 1))
            @test z.dists == [0, inf, inf]
            @test z.parents == [0, 0, 0]
        end
    end
    
    @testset "Random Graphs" begin
        @testset "Simple graphs" begin
            for i = 1:5
                nvg = Int(floor(500*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                G = SimpleGraph(nvg, neg; seed = seed)
                for g in testgraphs(G)
                    z = desopo_pape_shortest_paths(g, 1)
                    y = dijkstra_shortest_paths(g, 1)
                    @test isapprox(z.dists, y.dists)
                end
            end
        end

        @testset "Simple DiGraphs" begin
            for i = 1:5
                nvg = Int(floor(500*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                G = SimpleDiGraph(nvg, neg; seed = seed)
                for g in testgraphs(G)
                    z = desopo_pape_shortest_paths(g, 1)
                    y = dijkstra_shortest_paths(g, 1)
                    @test isapprox(z.dists, y.dists)
                end
            end
        end
    end
    
    @testset "Different types of graph" begin
        G = CompleteGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = CompleteDiGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = CycleGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = CycleDiGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = StarGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = WheelGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = RoachGraph(9)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        G = CliqueGraph(5, 19)
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)

        @testset "Small Graphs" begin
            for s in [:bull, :chvatal, :cubical, :desargues, 
                      :diamond, :dodecahedral, :frucht, :heawood, 
                      :house, :housex, :icosahedral, :krackhardtkite, :moebiuskantor,
                      :octahedral, :pappus, :petersen, :sedgewickmaze, :tutte, 
                      :tetrahedral, :truncatedcube, :truncatedtetrahedron, :truncatedtetrahedron_dir]
                G = smallgraph(s)
                z = desopo_pape_shortest_paths(G, 1)
                y = dijkstra_shortest_paths(G, 1)
                @test isapprox(z.dists, y.dists)
            end
        end 
    end
        
end
