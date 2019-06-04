@testset "D'Esopo-Pape" begin

    g4 = PathDiGraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    @testset "generic tests: $g" for g in testdigraphs(g4)
        y = @inferred(desopo_pape_shortest_paths(g, 2, d1))
        z = @inferred(desopo_pape_shortest_paths(g, 2, d2))
        @test y.parents == z.parents == [0, 0, 2, 3, 4]
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
    end

    gx = PathGraph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100
    @testset "cycles: $g" for g in testgraphs(gx)
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

    @testset "more cycles: $g" for g in testgraphs(G)
        y = @inferred(desopo_pape_shortest_paths(g, 1, m))
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
        z = @inferred(desopo_pape_shortest_paths(g, 1 , m))
        y = @inferred(dijkstra_shortest_paths(g, 1, m))
        @test isapprox(z.dists, y.dists)
    end

    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 4, 5)
    inf = typemax(eltype(G))
    @testset "disconnected: $g" for g in testgraphs(G)
        z = @inferred(desopo_pape_shortest_paths(g, 1))
        @test z.dists == [0, 1, 1, inf, inf]
        @test z.parents == [0, 1, 1, 0, 0]
    end

    G = SimpleGraph(3)
    inf = typemax(eltype(G))
    @testset "empty: $g" for g in testgraphs(G)
        z = @inferred(desopo_pape_shortest_paths(g, 1))
        @test z.dists == [0, inf, inf]
        @test z.parents == [0, 0, 0]
    end

    @testset "random simple graphs" begin
        for i = 1:5
            nvg = Int(ceil(250*rand()))
            neg = Int(floor((nvg*(nvg-1)/2)*rand()))
            rng = MersenneTwister(Int(floor(100*rand())))
            g = SimpleGraph(nvg, neg; rng=rng)
            z = desopo_pape_shortest_paths(g, 1)
            y = dijkstra_shortest_paths(g, 1)
            @test isapprox(z.dists, y.dists)
        end
    end

    @testset "random simple digraphs" begin
        for i = 1:5
            nvg = Int(ceil(250*rand()))
            neg = Int(floor((nvg*(nvg-1)/2)*rand()))
            rng = MersenneTwister(Int(floor(100*rand())))
            g = SimpleDiGraph(nvg, neg; rng=rng)
            z = desopo_pape_shortest_paths(g, 1)
            y = dijkstra_shortest_paths(g, 1)
            @test isapprox(z.dists, y.dists)
        end
    end

    @testset "misc graphs" begin
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
        rng = MersenneTwister(Int(floor(100*rand())))
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
        z = desopo_pape_shortest_paths(G, 1)
        y = dijkstra_shortest_paths(G, 1)
        @test isapprox(z.dists, y.dists)
    end

    @testset "errors" begin
        g = Graph()
        @test_throws DomainError desopo_pape_shortest_paths(g, 1)
        g = Graph(5)
        @test_throws DomainError desopo_pape_shortest_paths(g, 6)
    end
end
