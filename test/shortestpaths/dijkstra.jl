@testset "Dijkstra" begin
    g4 = PathDiGraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

    for g in testdigraphs(g4)
        y = @inferred(dijkstra_shortest_paths(g, 2, d1))
        z = @inferred(dijkstra_shortest_paths(g, 2, d2))

        @test y.parents == z.parents == [0, 0, 2, 3, 4]
        @test y.dists == z.dists == [Inf, 0, 6, 17, 33]

        y = @inferred(dijkstra_shortest_paths(g, 2, d1; allpaths=true))
        z = @inferred(dijkstra_shortest_paths(g, 2, d2; allpaths=true))
        @test z.predecessors[3] == y.predecessors[3] == [2]

        @test @inferred(enumerate_paths(z)) == enumerate_paths(y)
        @test @inferred(enumerate_paths(z))[4] ==
          enumerate_paths(z, 4) ==
          enumerate_paths(y, 4) == [2, 3, 4]
    end

    gx = PathGraph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100
    for g in testgraphs(gx)
        z = @inferred(dijkstra_shortest_paths(g, 1, d))
        @test z.dists == [0, 1, 3, 2, 3]
        @test z.parents == [0, 1, 4, 2, 4]
    end

    # small function to reconstruct the shortest path; I copied it from somewhere, can't find the original source to give the credits
    # @Beatzekatze on github
    spath(target, dijkstraStruct, source) = target == source ? target : [spath(dijkstraStruct.parents[target], dijkstraStruct, source) target]
    spaths(ds, targets, source) = [spath(i, ds, source) for i in targets]

    G = LightGraphs.Graph()
    add_vertices!(G, 4)
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
        ds = @inferred(dijkstra_shortest_paths(g, 2, w))
      # this loop reconstructs the shortest path for vertices 1, 3 and 4
        @test spaths(ds, [1, 3, 4], 2) == Array[[2 1],
                                            [2 3],
                                            [2 1 4]]

    # here a selflink at source is introduced; it should not change the shortest paths
        w[2, 2] = 10.0
        ds = @inferred(dijkstra_shortest_paths(g, 2, w))
        shortest_paths = []
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
        ds = @inferred(dijkstra_shortest_paths(g, 1, m; allpaths=true))
        @test ds.pathcounts   == [1, 1, 1, 1, 2]
        @test ds.predecessors == [[], [1], [1], [3], [3, 4]]
        @test ds.predecessors == [[], [1], [1], [3], [3, 4]]

        dm = @inferred(dijkstra_shortest_paths(g, 1; allpaths=true, trackvertices=true))
        @test dm.pathcounts       == [1, 1, 1, 1, 2]
        @test dm.predecessors     == [[], [1], [1], [3], [2, 3]]
        @test dm.closest_vertices == [1, 2, 3, 5, 4]
    end

    G = SimpleGraph(5)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 4, 5)
    for g in testgraphs(G)
        dm = @inferred(dijkstra_shortest_paths(g, 1; allpaths=true, trackvertices=true))
        @test dm.closest_vertices == [1, 2, 3, 4, 5]
    end

    #Testing multisource On undirected Graph
    g3 = PathGraph(5)
    d = [0 1 2 3 4; 1 0 1 0 1; 2 1 0 11 12; 3 0 11 0 5; 4 1 19 5 0]

    for g in testgraphs(g3)
        z  = @inferred(floyd_warshall_shortest_paths(g, d))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                    @test state.parents[j] == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = dijkstra_shortest_paths(g, i;allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end
    end


    #Testing multisource On directed Graph
    g3 = PathDiGraph(5)
    d = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])

    for g in testdigraphs(g3)
        z  = @inferred(floyd_warshall_shortest_paths(g, d))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, collect(1:5), d))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g))
        @test all(isapprox(z.dists, zp.dists))

        for i in 1:5
            state = dijkstra_shortest_paths(g, i; allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end

        z  = @inferred(floyd_warshall_shortest_paths(g))
        zp = @inferred(parallel_multisource_dijkstra_shortest_paths(g, [1, 2]))
        @test all(isapprox(z.dists[1:2, :], zp.dists))

        for i in 1:2
            state = dijkstra_shortest_paths(g, i;allpaths=true);
            for j in 1:5
                if z.parents[i, j] != 0
                    @test z.parents[i, j] in state.predecessors[j]
                else
                    @test length(state.predecessors[j]) == 0
                end
            end
        end
    end
end
