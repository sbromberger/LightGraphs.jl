@testset "Yen" begin
    g4 = path_digraph(5)
    d1 = float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])
    d2 = sparse(float([0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))

    for g in testdigraphs(g4)
        x = @inferred(yen_k_shortest_paths(g, 5, 5))
        @test length(x.dists) == length(x.paths) ==  1
        @test x.dists[1] ==  0
        @test x.paths[1] ==  [5]

        y = @inferred(yen_k_shortest_paths(g, 2, 5, d1, 1))
        z = @inferred(yen_k_shortest_paths(g, 2, 5, d2, 1))

        @test length(y.dists) == length(z.dists) == 1
        @test length(y.paths) == length(z.paths) == 1
        @test y.dists == z.dists == [33.0]
        @test z.paths == y.paths == [[2, 3, 4, 5]]

        # Remove edge to test empty paths
        rem_edge!(g, 1, 2)
        x = @inferred(yen_k_shortest_paths(g, 1, 5))
        @test length(x.dists) == length(x.paths) ==  0
    end

    gx = path_graph(5)
    add_edge!(gx, 2, 4)
    d = ones(Int, 5, 5)
    d[2, 3] = 100

    for g in testgraphs(gx)
        z = @inferred(yen_k_shortest_paths(g, 1, 5, d, 1))
        @test length(z.dists) == 1
        @test z.dists == [3]
        @test z.paths[1] == [1, 2, 4, 5]
    end


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
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w))
        @test ds.paths == [[2, 1, 4]]
        ds = @inferred(yen_k_shortest_paths(g, 2, 1, w))
        @test ds.paths == [[2, 1]]
        ds = @inferred(yen_k_shortest_paths(g, 2, 3, w))
        @test ds.paths == [[2, 3]]

        # Test with multiple paths
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w, 2))
        @test ds.paths == [[2, 1, 4], [2, 3, 4]]

        # here a selflink at source is introduced; it should not change the shortest paths
        w[2, 2] = 10.0
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w))
        @test ds.paths == [[2, 1, 4]]
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w, 3))
        @test ds.paths == [[2, 1, 4], [2, 3, 4]]

        # Test with new short link
        add_edge!(g, 2, 4)
        w[2, 4] = 1.
        w[4, 2] = 1.
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w, 2))
        @test ds.paths == [[2, 4], [2, 1, 4]]
        ds = @inferred(yen_k_shortest_paths(g, 2, 4, w, 3))
        @test ds.paths == [[2, 4], [2, 1, 4], [2, 3, 4]]
    end

    # Testing with the example in https://en.wikipedia.org/wiki/Yen%27s_algorithm
    G = LightGraphs.DiGraph()
    add_vertices!(G, 6)
    add_edge!(G, 1, 2)
    add_edge!(G, 1, 3)
    add_edge!(G, 2, 4)
    add_edge!(G, 3, 2)
    add_edge!(G, 3, 4)
    add_edge!(G, 3, 5)
    add_edge!(G, 4, 5)
    add_edge!(G, 4, 6)
    add_edge!(G, 5, 6)
    w = [0. 3. 2. 0. 0. 0.;
        0. 0. 0. 4. 0. 0.;
        0. 1. 0. 2. 3. 0.;
        0. 0. 0. 0. 2. 1.;
        0. 0. 0. 0. 0. 2.;
        0. 0. 0. 0. 0. 0.;]

    for g in testdigraphs(G)
        ds = @inferred(yen_k_shortest_paths(g, 1, 6, w, 3))
        @test ds.dists == [5., 7., 8.]
        @test ds.paths[1] == [1, 3, 4, 6]
        @test ds.paths[2] == [1, 3, 5, 6]
    end

    # Test all the paths
    add_edge!(G, 1, 4)
    w[1, 4] = 3
    w[4, 1] = 3
    for g in testdigraphs(G)
        ds = @inferred(yen_k_shortest_paths(G, 1, 6, w, 100))
        @test ds.dists == [4.0, 5.0, 7.0, 7.0, 8.0, 8.0, 8.0, 11.0, 11.0]

        ds = @inferred(yen_k_shortest_paths(G, 1, 6, w, 100, maxdist=7))
        @test ds.dists == [4.0, 5.0, 7.0, 7.0]
    end
end
