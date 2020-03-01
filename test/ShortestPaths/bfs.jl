    @testset "BFS" begin
        g1 = path_graph(5)
        g2 = path_digraph(5)
        s1 = shortest_paths(g1, 1) # bfs
        s2 = shortest_paths(g2, 1) # bfs
        @test paths(s1)[2] == paths(s1, 2) == [1, 2]
        @test paths(s2)[2] == paths(s2, 2) == [1, 2]
        @test dists(s1)[2] == dists(s1, 2) == 1
        @test dists(s2)[2] == dists(s2, 2) == 1
        add_edge!(g1, 2, 5)
        add_edge!(g2, 2, 5)
        for g in testgraphs(g1, g2)
            d = shortest_paths(g, 1, Dijkstra())
            b = shortest_paths(g, 1, BFS())
            q = shortest_paths(g, 1, BFS(Base.Sort.QuickSort))
            @test dists(d) == dists(b) && paths(d) == paths(b)
            @test dists(b) == dists(q) && paths(b) == paths(q)
            d2 = shortest_paths(g, [1, 3], Dijkstra())
            b2 = shortest_paths(g, [1, 3], BFS(NOOPSort))
            q2 = shortest_paths(g, [1, 3], BFS(Base.Sort.MergeSort))
            @test dists(d2) == dists(b2) && paths(d2) == paths(b2)
            @test dists(b2) == dists(q2) && paths(b2) == paths(q2)
        end

        @test shortest_paths(g1, 1) isa ShortestPaths.BFSResult
        @test shortest_paths(g2, 1) isa ShortestPaths.BFSResult
        m1 = shortest_paths(g1, [1, 2])
        m2 = shortest_paths(g2, [1, 2])
        @test m1 isa ShortestPaths.BFSResult
        @test m2 isa ShortestPaths.BFSResult
        @test m1.dists == [0, 0, 1, 2, 1]
        @test m2.dists == [0, 0, 1, 2, 1]

        @testset "maximum distance setting limits paths found" begin
            G = cycle_graph(8)
            add_edge!(G, 1, 3)
            
            for g in testgraphs(G)
                b = shortest_paths(g, 1, BFS(maxdist=2))
                @test b.dists == [0, 1, 1, 2, typemax(eltype(b.dists)), typemax(eltype(b.dists)), 2, 1]
            end
        end
    end
