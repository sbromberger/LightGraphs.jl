    @testset "ShortestPaths.DEsopoPape" begin
        g4 = path_digraph(5)
        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
        @testset "generic tests: $g" for g in testdigraphs(g4)
            y = @inferred(ShortestPaths.shortest_paths(g, 2, d1, ShortestPaths.DEsopoPape()))
            z = @inferred(ShortestPaths.shortest_paths(g, 2, d2, ShortestPaths.DEsopoPape()))
            @test y.parents == z.parents == [0, 0, 2, 3, 4]
            @test ShortestPaths.distances(y) == ShortestPaths.distances(z) == [Inf, 0, 6, 17, 33]
        end
            
        gx = path_graph(5)
        add_edge!(gx, 2, 4)
        d = ones(Int, 5, 5)
        d[2, 3] = 100
        @testset "cycles: $g" for g in testgraphs(gx)
            z = @inferred(ShortestPaths.shortest_paths(g, 1, d, ShortestPaths.DEsopoPape()))
            @test ShortestPaths.distances(z) == [0, 1, 3, 2, 3]
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

        @testset "more cycles: $g" for g in testgraphs(G)
            y = @inferred(ShortestPaths.shortest_paths(g, 1, m, ShortestPaths.DEsopoPape()))
            @test y.parents == [0, 1, 1, 3, 3]
            @test ShortestPaths.distances(y) == [0, 2, 2, 3, 4]
        end

        G = SimpleGraph(5)
        add_edge!(G, 2, 2)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 3, 3)
        add_edge!(G, 1, 5)
        add_edge!(G, 2, 4)
        add_edge!(G, 4, 5)
        m = [0 10 2 0 15; 10 9 0 1 0; 2 0 1 0 0; 0 1 0 0 2; 15 0 0 2 0]
        @testset "self loops: $g" for g in testgraphs(G)
            z = @inferred(ShortestPaths.shortest_paths(g, 1, m, ShortestPaths.DEsopoPape()))
            y = @inferred(ShortestPaths.shortest_paths(g, 1, m, ShortestPaths.Dijkstra()))
            @test isapprox(ShortestPaths.distances(z), ShortestPaths.distances(y))
        end

        G = SimpleGraph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 4, 5)
        inf = typemax(eltype(G))
        @testset "disconnected: $g" for g in testgraphs(G)
            z = @inferred(ShortestPaths.shortest_paths(g, 1, ShortestPaths.DEsopoPape()))
            @test ShortestPaths.distances(z) == [0, 1, 1, inf, inf]
            @test z.parents == [0, 1, 1, 0, 0]
        end

        G = SimpleGraph(3)
        inf = typemax(eltype(G))
        @testset "empty: $g" for g in testgraphs(G)
            z = @inferred(ShortestPaths.shortest_paths(g, 1, ShortestPaths.DEsopoPape()))
            @test ShortestPaths.distances(z) == [0, inf, inf]
            @test z.parents == [0, 0, 0]
        end
        @testset "random simple graphs" begin
            for i = 1:5
                nvg = Int(ceil(250*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                g = SimpleGraph(nvg, neg; seed = seed)
                z = ShortestPaths.shortest_paths(g, 1, ShortestPaths.DEsopoPape())
                y = ShortestPaths.shortest_paths(g, 1, ShortestPaths.Dijkstra())
                @test isapprox(ShortestPaths.distances(z), ShortestPaths.distances(y))
            end
        end

        @testset "random simple digraphs" begin
            for i = 1:5
                nvg = Int(ceil(250*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                g = SimpleDiGraph(nvg, neg; seed = seed)
                z = ShortestPaths.shortest_paths(g, 1, ShortestPaths.DEsopoPape())
                y = ShortestPaths.shortest_paths(g, 1, ShortestPaths.Dijkstra())
                @test isapprox(ShortestPaths.distances(z), ShortestPaths.distances(y))
            end
        end

        @testset "misc graphs" begin
            for G in [ complete_graph(9), complete_digraph(9), cycle_graph(9), cycle_digraph(9),
                      star_graph(9), wheel_graph(9), roach_graph(9), clique_graph(5, 19) ]
                z = ShortestPaths.shortest_paths(G, 1, ShortestPaths.DEsopoPape())
                y = ShortestPaths.shortest_paths(G, 1, ShortestPaths.Dijkstra())
                @test isapprox(ShortestPaths.distances(z), ShortestPaths.distances(y))
            end
        end

        @testset "smallgraphs: $s" for s in [
            :bull, :chvatal, :cubical, :desargues, 
            :diamond, :dodecahedral, :frucht, :heawood, 
            :house, :housex, :icosahedral, :krackhardtkite, :moebiuskantor,
            :octahedral, :pappus, :petersen, :sedgewickmaze, :tutte, 
            :tetrahedral, :truncatedcube, :truncatedtetrahedron,
            :truncatedtetrahedron_dir
         ]
            G = smallgraph(s)
            z = ShortestPaths.shortest_paths(G, 1, ShortestPaths.DEsopoPape())
            y = ShortestPaths.shortest_paths(G, 1, ShortestPaths.Dijkstra())
            @test isapprox(ShortestPaths.distances(z), ShortestPaths.distances(y))
        end

        @testset "maximum distance setting limits paths found" begin
            G = cycle_graph(6)
            add_edge!(G, 1, 3)
            m = float([0 2 2 0 0 1; 2 0 1 0 0 0; 2 1 0 4 0 0; 0 0 4 0 1 0; 0 0 0 1 0 1; 1 0 0 0 1 0])

            for g in testgraphs(G)
                ds = @inferred(ShortestPaths.shortest_paths(G, 3, m, ShortestPaths.DEsopoPape(maxdist=3)))
                @test ShortestPaths.distances(ds) == [2, 1, 0, Inf, Inf, 3]
            end
        end 
        
        @testset "errors" begin
            g = Graph()
            @test_throws DomainError ShortestPaths.shortest_paths(g, 1, ShortestPaths.DEsopoPape())
            g = Graph(5)
            @test_throws DomainError ShortestPaths.shortest_paths(g, 6, ShortestPaths.DEsopoPape())
        end
    end
