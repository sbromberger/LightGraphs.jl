    @testset "DEsopoPape" begin
        g4 = path_digraph(5)
        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
        @testset "generic tests: $g" for g in testdigraphs(g4)
            y = @inferred(shortest_paths(g, 2, d1, DEsopoPape()))
            z = @inferred(shortest_paths(g, 2, d2, DEsopoPape()))
            @test y.parents == z.parents == [0, 0, 2, 3, 4]
            @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
        end
            
        gx = path_graph(5)
        add_edge!(gx, 2, 4)
        d = ones(Int, 5, 5)
        d[2, 3] = 100
        @testset "cycles: $g" for g in testgraphs(gx)
            z = @inferred(shortest_paths(g, 1, d, DEsopoPape()))
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

        @testset "more cycles: $g" for g in testgraphs(G)
            y = @inferred(shortest_paths(g, 1, m, DEsopoPape()))
            @test y.parents == [0, 1, 1, 3, 3]
            @test y.dists == [0, 2, 2, 3, 4]
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
            z = @inferred(shortest_paths(g, 1, m, DEsopoPape()))
            y = @inferred(shortest_paths(g, 1, m, Dijkstra()))
            @test isapprox(z.dists, y.dists)
        end

        G = SimpleGraph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 4, 5)
        inf = typemax(eltype(G))
        @testset "disconnected: $g" for g in testgraphs(G)
            z = @inferred(shortest_paths(g, 1, DEsopoPape()))
            @test z.dists == [0, 1, 1, inf, inf]
            @test z.parents == [0, 1, 1, 0, 0]
        end

        G = SimpleGraph(3)
        inf = typemax(eltype(G))
        @testset "empty: $g" for g in testgraphs(G)
            z = @inferred(shortest_paths(g, 1, DEsopoPape()))
            @test z.dists == [0, inf, inf]
            @test z.parents == [0, 0, 0]
        end
        @testset "random simple graphs" begin
            for i = 1:5
                nvg = Int(ceil(250*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                g = SimpleGraph(nvg, neg; rng=Random.MersenneTwister(seed))
                z = shortest_paths(g, 1, DEsopoPape())
                y = shortest_paths(g, 1, Dijkstra())
                @test isapprox(z.dists, y.dists)
            end
        end

        @testset "random simple digraphs" begin
            for i = 1:5
                nvg = Int(ceil(250*rand()))
                neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                seed = Int(floor(100*rand()))
                g = SimpleDiGraph(nvg, neg; rng=Random.MersenneTwister(seed))
                z = shortest_paths(g, 1, DEsopoPape())
                y = shortest_paths(g, 1, Dijkstra())
                @test isapprox(z.dists, y.dists)
            end
        end

        @testset "misc graphs" begin
            G = complete_graph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = complete_digraph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = cycle_graph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = cycle_digraph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = star_graph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = wheel_graph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = roach_graph(9)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)

            G = clique_graph(5, 19)
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)
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
            z = shortest_paths(G, 1, DEsopoPape())
            y = shortest_paths(G, 1, Dijkstra())
            @test isapprox(z.dists, y.dists)
        end

        @testset "maximum distance setting limits paths found" begin
            G = cycle_graph(6)
            add_edge!(G, 1, 3)
            m = float([0 2 2 0 0 1; 2 0 1 0 0 0; 2 1 0 4 0 0; 0 0 4 0 1 0; 0 0 0 1 0 1; 1 0 0 0 1 0])

            for g in testgraphs(G)
                ds = @inferred(shortest_paths(G, 3, m, DEsopoPape(maxdist=3)))
                @test ds.dists == [2, 1, 0, Inf, Inf, 3]
            end
        end 
        
        @testset "errors" begin
            g = Graph()
            @test_throws DomainError shortest_paths(g, 1, DEsopoPape())
            g = Graph(5)
            @test_throws DomainError shortest_paths(g, 6, DEsopoPape())
        end
    end
