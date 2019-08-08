using LightGraphs.Experimental, LightGraphs.Experimental.ShortestPaths
using SparseArrays

import Base.==
function ==(a::ShortestPaths.AStarResults, b::ShortestPaths.AStarResults)
   return a.path == b.path && a.dist == b.dist
end
@testset "Shortest Paths" begin
    smallgs = [smallgraph(x) for x in [:house, :housex, :tutte, :karate, :petersen, :truncatedtetrahedron_dir]]
    wg = path_graph(4); add_edge!(wg, 2, 4)
    w = ones(4,4)
    for i in 1:4
        w[i,i] = 0
    end
    w[2,3] = w[3,2] = 10

    @testset "AStar" begin
        g3 = path_graph(5)
        g4 = path_digraph(5)

        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
        for g in testgraphs(g3), dg in testdigraphs(g4)
            @test @inferred(shortest_paths(g, 1, 4, d1, AStar())) ==
            @inferred(shortest_paths(dg, 1, 4, d1, AStar())) ==
            @inferred(shortest_paths(g, 1, 4, d2, AStar()))
            z = @inferred(shortest_paths(dg, 4, 1, AStar()))
            @test isempty(z.path)
        end
    end

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
            @test @inferred(!has_negative_edge_cycle(g))
            @test @inferred(!has_negative_edge_cycle(g, d1))


            y = @inferred(shortest_paths(g, 2, d1, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, d2, BellmanFord()))
            @test dists(y) == dists(z) == [Inf, 0, 6, 17, 33]
            @test @inferred(paths(z))[2] == []
            @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
            @test @inferred(!has_negative_edge_cycle(g))
            z = @inferred(shortest_paths(g, 2, BellmanFord()))
            @test dists(z) == [typemax(Int), 0, 1, 2, 3]
        end

        # Negative Cycle
        gx = complete_graph(3)
        for g in testgraphs(gx)
            d = [1 -3 1; -3 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_edge_cycle(g, d)

            d = [1 -1 1; -1 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_edge_cycle(g, d)
        end

        # Negative cycle of length 3 in graph of diameter 4
        gx = complete_graph(4)
        d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
        for g in testgraphs(gx)
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_edge_cycle(g, d)
        end
    end

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
                g = SimpleGraph(nvg, neg; seed = seed)
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
                g = SimpleDiGraph(nvg, neg; seed = seed)
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
        
        @testset "errors" begin
            g = Graph()
            @test_throws DomainError shortest_paths(g, 1, DEsopoPape())
            g = Graph(5)
            @test_throws DomainError shortest_paths(g, 6, DEsopoPape())
        end
    end

    @testset "Dijkstra" begin
        g4 = path_digraph(5)
        d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
        d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

        for g in testdigraphs(g4)
            y = @inferred(shortest_paths(g, 2, d1, Dijkstra()))
            z = @inferred(shortest_paths(g, 2, d2, Dijkstra()))

            @test y.parents == z.parents == [0, 0, 2, 3, 4]
            @test y.dists == z.dists == [Inf, 0, 6, 17, 33]

            y = @inferred(shortest_paths(g, 2, d1, Dijkstra(all_paths=true)))
            z = @inferred(shortest_paths(g, 2, d2, Dijkstra(all_paths=true)))
            @test z.predecessors[3] == y.predecessors[3] == [2]

            @test @inferred(paths(z)) == paths(y)
            @test @inferred(paths(z))[4] == paths(z, 4) == paths(y, 4) == [2, 3, 4]
        end

        gx = path_graph(5)
        add_edge!(gx, 2, 4)
        d = ones(Int, 5, 5)
        d[2, 3] = 100
        for g in testgraphs(gx)
            z = @inferred(shortest_paths(g, 1, d, Dijkstra()))
            @test z.dists == [0, 1, 3, 2, 3]
            @test z.parents == [0, 1, 4, 2, 4]
        end

        # small function to reconstruct the shortest path; I copied it from somewhere,
        # can't find the original source to give the credits
        # @Beatzekatze on github
        spath(target, dijkstraStruct, source) = target == source ? target : [spath(dijkstraStruct.parents[target], dijkstraStruct, source) target]
        spaths(ds, targets, source) = [spath(i, ds, source) for i in targets]

        G = Graph(4)
        add_edge!(G, 2, 1)
        add_edge!(G, 2, 3)
        add_edge!(G, 1, 4)
        add_edge!(G, 3, 4)
        add_edge!(G, 2, 2)
        w = [0. 3. 0. 1.;
            3. 0. 2. 0.;
            0. 2. 0. 3.;
            1. 0. 3. 0.]

        for g in testgraphs(G)
            ds = @inferred(shortest_paths(g, 2, w, Dijkstra()) )
          # this loop reconstructs the shortest path for vertices 1, 3 and 4
            @test spaths(ds, [1, 3, 4], 2) == Array[[2 1],
                                                [2 3],
                                                [2 1 4]]

        # here a selflink at source is introduced; it should not change the shortest paths
            w[2, 2] = 10.0
            ds = @inferred(shortest_paths(g, 2, w, Dijkstra()))
          # this loop reconstructs the shortest path for vertices 1, 3 and 4
            @test spaths(ds, [1, 3, 4], 2) == Array[[2 1],
                                                [2 3],
                                                [2 1 4]]
        end

        #615
        m = [0 2 2 0 0; 2 0 0 0 3; 2 0 0 1 2;0 0 1 0 1;0 3 2 1 0]
        G = SimpleGraph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 2, 5)
        add_edge!(G, 3, 5)
        add_edge!(G, 3, 4)
        add_edge!(G, 4, 5)
        for g in testgraphs(G)
            ds = @inferred(shortest_paths(g, 1, m, Dijkstra(all_paths=true)))
            @test ds.pathcounts   == [1, 1, 1, 1, 2]
            @test ds.predecessors == [[], [1], [1], [3], [3, 4]]
            @test ds.predecessors == [[], [1], [1], [3], [3, 4]]

            dm = @inferred(shortest_paths(g, 1, Dijkstra(all_paths=true, track_vertices=true)))
            @test dm.pathcounts       == [1, 1, 1, 1, 2]
            @test dm.predecessors     == [[], [1], [1], [3], [2, 3]]
            @test dm.closest_vertices == [1, 2, 3, 5, 4]
        end

        G = SimpleGraph(5)
        add_edge!(G, 1, 2)
        add_edge!(G, 1, 3)
        add_edge!(G, 4, 5)
        for g in testgraphs(G)
            dm = @inferred(shortest_paths(g, 1, Dijkstra(all_paths=true, track_vertices=true)))
            @test dm.closest_vertices == [1, 2, 3, 4, 5]
        end
    end

    @testset "FloydWarshall" begin
        g3 = path_graph(5)
        d = [0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]
        for g in testgraphs(g3)
            z = @inferred(shortest_paths(g, d, FloydWarshall()))
            @test z.dists[3, :][:] == [7, 6, 0, 11, 27]
            @test z.parents[3, :][:] == [2, 3, 0, 3, 4]

            @test @inferred(paths(z))[2][2] == []
            @test @inferred(paths(z))[2][4] == paths(z, 2)[4] == paths(z, 2, 4) == [2, 3, 4]
        end
        g4 = path_digraph(4)
        d = ones(4, 4)
        for g in testdigraphs(g4)
            z = @inferred(shortest_paths(g, d, FloydWarshall()))
            @test length(paths(z, 4, 3)) == 0
            @test length(paths(z, 4, 1)) == 0
            @test length(paths(z, 2, 3)) == 2
        end 

        g5 = DiGraph([1 1 1 0 1; 0 1 0 1 1; 0 1 1 0 0; 1 0 1 1 0; 0 0 0 1 1])
        d = [0 3 8 0 -4; 0 0 0 1 7; 0 4 0 0 0; 2 0 -5 0 0; 0 0 0 6 0]
        for g in testdigraphs(g5)
            z = @inferred(shortest_paths(g, d, FloydWarshall()))
            @test z.dists == [0 1 -3 2 -4; 3 0 -4 1 -1; 7 4 0 5 3; 2 -1 -5 0 -2; 8 5 1 6 0]
        end 

        @testset "paths infinite loop bug" begin
            g = SimpleGraph(2)
            add_edge!(g, 1, 2)
            add_edge!(g, 2, 2)
            @test paths(shortest_paths(g, FloydWarshall())) ==
                Vector{Vector{Int}}[[[], [1, 2]], [[2, 1], []]]

            g = SimpleDiGraph(2)
            add_edge!(g, 1, 1)
            add_edge!(g, 1, 2)
            add_edge!(g, 2, 1)
            add_edge!(g, 2, 2)
            @test paths(shortest_paths(g, FloydWarshall())) ==
                Vector{Vector{Int}}[[[], [1, 2]], [[2, 1], []]]
        end
    end

    @testset "Johnson" begin
        g3 = path_graph(5)
        d = Symmetric([0 1 2 3 4; 1 0 6 7 8; 2 6 0 11 12; 3 7 11 0 16; 4 8 12 16 0])
        for g in testgraphs(g3)
            z = @inferred(shortest_paths(g, d, Johnson()))
            @test z.dists[3, :][:] == [7, 6, 0, 11, 27]
            @test z.parents[3, :][:] == [2, 3, 0, 3, 4]

            @test @inferred(paths(z))[2][2] == []
            @test @inferred(paths(z))[2][4] == paths(z, 2)[4] == paths(z, 2, 4) == [2, 3, 4]
        end

        g4 = path_digraph(4)
        for g in testdigraphs(g4)
            z = @inferred(shortest_paths(g, Johnson()))
            @test length(paths(z, 4, 3)) == 0
            @test length(paths(z, 4, 1)) == 0
            @test length(paths(z, 2, 3)) == 2
        end 

        g5 = DiGraph([1 1 1 0 1; 0 1 0 1 1; 0 1 1 0 0; 1 0 1 1 0; 0 0 0 1 1])
        d = [0 3 8 0 -4; 0 0 0 1 7; 0 4 0 0 0; 2 0 -5 0 0; 0 0 0 6 0]
        for g in testdigraphs(g5)
            z = @inferred(shortest_paths(g, d, Johnson()))
            @test z.dists == [0 1 -3 2 -4; 3 0 -4 1 -1; 7 4 0 5 3; 2 -1 -5 0 -2; 8 5 1 6 0]
        end 
    end
end
