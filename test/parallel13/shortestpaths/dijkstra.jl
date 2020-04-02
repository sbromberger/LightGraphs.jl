@testset "Parallel.Dijkstra" begin
    g4 = path_digraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    #Testing multisource On undirected Graph
    g3 = path_graph(5)
    d = [0 1 2 3 4; 1 0 1 0 1; 2 1 0 11 12; 3 0 11 0 5; 4 1 19 5 0]

    for g in testgraphs(g3)
        z  = floyd_warshall_shortest_paths(g, d)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = LightGraphs.dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if zp.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end

        z  = floyd_warshall_shortest_paths(g)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = LightGraphs.dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if zp.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end

        z  = floyd_warshall_shortest_paths(g)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = LightGraphs.dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if zp.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end
    end


    #Testing multisource On directed Graph
    g3 = path_digraph(5)
    d = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])

    for g in testdigraphs(g3)
        z  = floyd_warshall_shortest_paths(g, d)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = LightGraphs.dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end

        z  = floyd_warshall_shortest_paths(g)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = LightGraphs.dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if zp.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end

        z  = floyd_warshall_shortest_paths(g)
        zp = @inferred(Parallel.dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = LightGraphs.dijkstra_shortest_paths(g, i;allpaths=true);
            for j in 1:5
                if zp.parents[i, j] != 0
                    @test zp.parents[i, j] in state.predecessors[j]
                end
            end
        end
    end
end
