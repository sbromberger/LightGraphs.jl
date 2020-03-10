@testset "Distributed Dijkstra" begin
    g4 = path_digraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
    #Testing multisource On undirected Graph
    g3 = path_graph(5)
    d = [0 1 2 3 4; 1 0 1 0 1; 2 1 0 11 12; 3 0 11 0 5; 4 1 19 5 0]

    for g in testgraphs(g3)
        z  = ShortestPaths.shortest_paths(g, d, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, collect(1:5), d, ShortestPaths.DistributedDijkstra()))
        zp2 = @inferred(ShortestPaths.shortest_paths(g, d, ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z), Traversals.dists(zp)))
        @test all(isapprox(Traversals.dists(z), Traversals.dists(zp2)))

        for i in 1:5
            state = ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true));
            for j in 1:5
                if Traversals.parents(zp)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end

        z  = ShortestPaths.shortest_paths(g, d, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, d, ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z), Traversals.dists(zp)))

        for i in 1:5
            state = ShortestPaths.shortest_paths(g, i, d, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true))
            for j in 1:5
                if Traversals.parents(zp)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end

        z  = ShortestPaths.shortest_paths(g, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, [1, 2], ShortestPaths.DistributedDijkstra()))
        zp2 = @inferred(ShortestPaths.shortest_paths(g, ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z)[1:2, :], Traversals.dists(zp)))
        @test all(isapprox(Traversals.dists(zp2)[1:2, :], Traversals.dists(zp)))

        for i in 1:2
            state = ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true))
            for j in 1:5
                if Traversals.parents(zp)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end

        zp = ShortestPaths.shortest_paths(g, ShortestPaths.DistributedDijkstra)
        for i in vertices(g)
            @test ShortestPaths.Traversals.dists(zp[i]) == ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra())
            @test ShortestPaths.shortest_paths(g, i, ShortestPaths.DistributedDijkstra()) == ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra())
        end

    end


    #Testing multisource On directed Graph
    g3 = path_digraph(5)
    d = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])

    for g in testdigraphs(g3)
        z  = ShortestPaths.shortest_paths(g, d, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, collect(1:5), d, ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z), Traversals.dists(zp)))

        for i in 1:5
            state = ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true))
            for j in 1:5
                if Traversals.parents(z)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end

        z  = ShortestPaths.shortest_paths(g, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z), Traversals.dists(zp)))

        for i in 1:5
            state = ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true))
            for j in 1:5
                if Traversals.parents(zp)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end

        z  = ShortestPaths.shortest_paths(g, ShortestPaths.FloydWarshall())
        zp = @inferred(ShortestPaths.shortest_paths(g, [1, 2], ShortestPaths.DistributedDijkstra()))
        @test all(isapprox(Traversals.dists(z)[1:2, :], Traversals.dists(zp)))

        for i in 1:2
            state = ShortestPaths.shortest_paths(g, i, ShortestPaths.Dijkstra(all_ShortestPaths.paths=true))
            for j in 1:5
                if Traversals.parents(zp)[i, j] != 0
                    @test Traversals.parents(zp)[i, j] in state.predecessors[j]
                end
            end
        end
    end
end
