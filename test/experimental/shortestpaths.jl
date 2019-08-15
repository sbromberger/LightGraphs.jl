using LightGraphs.Experimental, LightGraphs.Experimental.ShortestPaths
using SparseArrays

import Base.==
function ==(a::ShortestPaths.AStarResult, b::ShortestPaths.AStarResult)
   return a.path == b.path && a.dist == b.dist
end
@testset "Shortest Paths" begin

    g1 = path_graph(5)
    g2 = path_digraph(5)
    s1 = shortest_paths(g1, 1) # bfs
    s2 = shortest_paths(g2, 1) # bfs
    @test paths(s1)[2] == paths(s1, 2) == [1, 2]
    @test paths(s2)[2] == paths(s2, 2) == [1, 2]
    @test dists(s1)[2] == dists(s1, 2) == 1
    @test dists(s2)[2] == dists(s2, 2) == 1
    @test !has_negative_weight_cycle(g1)
    @test !has_negative_weight_cycle(g2)

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
            @test @inferred(!has_negative_weight_cycle(g, BellmanFord()))
            @test @inferred(!has_negative_weight_cycle(g, d1, BellmanFord()))


            y = @inferred(shortest_paths(g, 2, d1, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, d2, BellmanFord()))
            @test dists(y) == dists(z) == [Inf, 0, 6, 17, 33]
            @test @inferred(paths(z))[2] == []
            @test @inferred(paths(z))[4] == paths(z, 4) == [2, 3, 4]
            @test @inferred(!has_negative_weight_cycle(g, BellmanFord()))
            z = @inferred(shortest_paths(g, 2, BellmanFord()))
            @test dists(z) == [typemax(Int), 0, 1, 2, 3]
        end

        # Negative Cycle
        gx = complete_graph(3)
        for g in testgraphs(gx)
            d = [1 -3 1; -3 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d, BellmanFord())

            d = [1 -1 1; -1 1 1; 1 1 1]
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d, BellmanFord())
            @test has_negative_weight_cycle(g, d)
        end

        # Negative cycle of length 3 in graph of diameter 4
        gx = complete_graph(4)
        d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
        for g in testgraphs(gx)
            @test_throws NegativeCycleError shortest_paths(g, 1, d, BellmanFord())
            @test has_negative_weight_cycle(g, d)
        end
    end

    @testset "BFS" begin
        g1= path_graph(5)
        g2 = path_digraph(5)
        add_edge!(g1, 2, 5)
        add_edge!(g2, 2, 5)
        for g in testgraphs(g1, g2)
            d = shortest_paths(g, 1, Dijkstra())
            b = shortest_paths(g, 1, BFS())
            @test dists(d) == dists(b) && paths(d) == paths(b)
            d2 = shortest_paths(g, [1, 3], Dijkstra())
            b2 = shortest_paths(g, [1, 3], BFS())
            @test dists(d2) == dists(b2) && paths(d2) == paths(b2)
        end

        @test shortest_paths(g1, 1) isa ShortestPaths.BFSResult
        @test shortest_paths(g2, 1) isa ShortestPaths.BFSResult
        m1 = shortest_paths(g1, [1, 2])
        m2 = shortest_paths(g2, [1, 2])
        @test m1 isa ShortestPaths.BFSResult
        @test m2 isa ShortestPaths.BFSResult
        @test m1.dists == [0, 0, 1, 2, 1]
        @test m2.dists == [0, 0, 1, 2, 1]
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

    @testset "DFS" begin
        g1= path_graph(5)
        g2 = path_digraph(5)
        add_edge!(g1, 2, 5)
        add_edge!(g2, 2, 5)
        for g in testgraphs(g1, g2)
            d = shortest_paths(g, 1, BFS())
            b = shortest_paths(g, 1, DFS())
            @test dists(d) == dists(b) && paths(d) == paths(b)
            d2 = shortest_paths(g, [1, 3], BFS())
            b2 = shortest_paths(g, [1, 3], DFS())
            @test dists(d2) == dists(b2) && paths(d2) == paths(b2)
        end

        @test shortest_paths(g1, 1) isa ShortestPaths.DFSResult
        @test shortest_paths(g2, 1) isa ShortestPaths.DFSResult
        m1 = shortest_paths(g1, [1, 2])
        m2 = shortest_paths(g2, [1, 2])
        @test m1 isa ShortestPaths.DFSResult
        @test m2 isa ShortestPaths.DFSResult
        @test m1.dists == [0, 0, 1, 2, 1]
        @test m2.dists == [0, 0, 1, 2, 1]
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

            @test shortest_paths(g, 1, d1) isa ShortestPaths.DijkstraResult
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
        @testset "default for no source, no alg" begin
            g = path_graph(4)
            w = zeros(4,4)
            for i in 1:3
                w[i, i+1] = 1.0
                w[i+1, i] = 1.0
            end
            @test shortest_paths(g) isa ShortestPaths.FloydWarshallResult
            @test shortest_paths(g, w) isa ShortestPaths.FloydWarshallResult
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

    @testset "SPFA" begin
        @testset "Generic tests for graphs" begin
            g4 = path_digraph(5)
            d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])

            for g in testdigraphs(g4)
                y = @inferred(shortest_paths(g, 2, d1, SPFA()))
                @test y.dists == [Inf, 0, 6, 17, 33]
            end

            @testset "Graph with cycle" begin
                gx = path_graph(5)
                add_edge!(gx, 2, 4)
                d = ones(Int, 5, 5)
                d[2, 3] = 100
                for g in testgraphs(gx)
                    z = @inferred(shortest_paths(g, 1, d, SPFA()))
                    @test z.dists == [0, 1, 3, 2, 3]
                end
            end

            m = [0 2 2 0 0; 2 0 0 0 3; 2 0 0 1 2; 0 0 1 0 1; 0 3 2 1 0]
            G = SimpleGraph(5)
            add_edge!(G, 1, 2)
            add_edge!(G, 1, 3)
            add_edge!(G, 2, 5)
            add_edge!(G, 3, 5)
            add_edge!(G, 3, 4)
            add_edge!(G, 4, 5)

            for g in testgraphs(G)
                y = @inferred(shortest_paths(g, 1, m, SPFA()))
                @test y.dists == [0, 2, 2, 3, 4]
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
                z = @inferred(shortest_paths(g, 1 , m, SPFA()))
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
                z = @inferred(shortest_paths(g, 1, SPFA()))
                @test z.dists == [0, 1, 1, inf, inf]
            end
        end

        @testset "Empty graph" begin
            G = SimpleGraph(3)
            inf = typemax(eltype(G))
            for g in testgraphs(G)
                z = @inferred(shortest_paths(g, 1, SPFA()))
                @test z.dists == [0, inf, inf]
            end
        end

        @testset "Random Graphs" begin
            @testset "Simple graphs" begin
                for i = 1:5
                    nvg = Int(ceil(250*rand()))
                    neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                    seed = Int(floor(100*rand()))
                    g = SimpleGraph(nvg, neg; seed = seed)
                    z = shortest_paths(g, 1, SPFA())
                    y = dijkstra_shortest_paths(g, 1)
                    @test isapprox(z.dists, y.dists)
                end
            end

            @testset "Simple DiGraphs" begin
                for i = 1:5
                    nvg = Int(ceil(250*rand()))
                    neg = Int(floor((nvg*(nvg-1)/2)*rand()))
                    seed = Int(floor(100*rand()))
                    g = SimpleDiGraph(nvg, neg; seed = seed)
                    z = shortest_paths(g, 1, SPFA())
                    y = dijkstra_shortest_paths(g, 1)
                    @test isapprox(z.dists, y.dists)
                end
            end
        end

        @testset "Different types of graph" begin
            G = complete_graph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = complete_digraph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = cycle_graph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = cycle_digraph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = star_graph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = wheel_graph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = roach_graph(9)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            G = clique_graph(5, 19)
            z = shortest_paths(G, 1, SPFA())
            y = dijkstra_shortest_paths(G, 1)
            @test isapprox(z.dists, y.dists)

            @testset "Small Graphs" begin
                for s in [:bull, :chvatal, :cubical, :desargues,
                          :diamond, :dodecahedral, :frucht, :heawood,
                          :house, :housex, :icosahedral, :krackhardtkite, :moebiuskantor,
                          :octahedral, :pappus, :petersen, :sedgewickmaze, :tutte,
                          :tetrahedral, :truncatedcube, :truncatedtetrahedron, :truncatedtetrahedron_dir]
                    G = smallgraph(s)
                    z = shortest_paths(G, 1, SPFA())
                    y = dijkstra_shortest_paths(G, 1)
                    @test isapprox(z.dists, y.dists)
                end
            end
        end

        @testset "Normal graph" begin
            g4 = path_digraph(5)

            d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
            d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
            for g in testdigraphs(g4)
                y = @inferred(shortest_paths(g, 2, d1, SPFA()))
                z = @inferred(shortest_paths(g, 2, d2, SPFA()))
                @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
                @test @inferred(!has_negative_weight_cycle(g, SPFA()))
                @test @inferred(!has_negative_weight_cycle(g, d1, SPFA()))


                y = @inferred(shortest_paths(g, 2, d1, SPFA()))
                z = @inferred(shortest_paths(g, 2, d2, SPFA()))
                @test y.dists == z.dists == [Inf, 0, 6, 17, 33]
                @test @inferred(!has_negative_weight_cycle(g, SPFA()))
                z = @inferred(shortest_paths(g, 2, SPFA()))
                @test z.dists == [typemax(Int), 0, 1, 2, 3]
            end
        end


        @testset "Negative Cycle" begin
            # Negative Cycle 1
            gx = complete_graph(3)
            for g in testgraphs(gx)
                d = [1 -3 1; -3 1 1; 1 1 1]
                @test_throws ShortestPaths.NegativeCycleError shortest_paths(g, 1, d, SPFA())
                @test has_negative_weight_cycle(g, d, SPFA())

                d = [1 -1 1; -1 1 1; 1 1 1]
                @test_throws ShortestPaths.NegativeCycleError shortest_paths(g, 1, d, SPFA())
                @test has_negative_weight_cycle(g, d, SPFA())
            end

            # Negative cycle of length 3 in graph of diameter 4
            gx = complete_graph(4)
            d = [1 -1 1 1; 1 1 1 -1; 1 1 1 1; 1 1 1 1]
            for g in testgraphs(gx)
                @test_throws ShortestPaths.NegativeCycleError shortest_paths(g, 1, d, SPFA())
                @test has_negative_weight_cycle(g, d, SPFA())
            end
        end

    end
end
