    @testset "ShortestPaths.BFS" begin
        g1 = path_graph(5)
        g2 = path_digraph(5)
        s1 = ShortestPaths.shortest_paths(g1, 1) # bfs
        s2 = ShortestPaths.shortest_paths(g2, 1) # bfs
        @test ShortestPaths.paths(s1)[2] == ShortestPaths.paths(s1, 2) == [1, 2]
        @test ShortestPaths.paths(s2)[2] == ShortestPaths.paths(s2, 2) == [1, 2]
        @test Traversals.dists(s1[2] == Traversals.dists(s1, 2) == 1
        @test Traversals.dists(s2)[2] == Traversals.dists(s2, 2) == 1
        add_edge!(g1, 2, 5)
        add_edge!(g2, 2, 5)
        for g in testgraphs(g1, g2)
            d = ShortestPaths.shortest_paths(g, 1, ShortestPaths.Dijkstra())
            b = ShortestPaths.shortest_paths(g, 1, ShortestPaths.BFS())
            q = ShortestPaths.shortest_paths(g, 1, ShortestPaths.BFS(Base.Sort.QuickSort))
            @test Traversals.dists(d) == Traversals.dists(b) && ShortestPaths.paths(d) == ShortestPaths.paths(b)
            @test Traversals.dists(b) == Traversals.dists(q) && ShortestPaths.paths(b) == ShortestPaths.paths(q)
            d2 = ShortestPaths.shortest_paths(g, [1, 3], ShortestPaths.Dijkstra())
            b2 = ShortestPaths.shortest_paths(g, [1, 3], ShortestPaths.BFS(NOOPSort))
            q2 = ShortestPaths.shortest_paths(g, [1, 3], ShortestPaths.BFS(Base.Sort.MergeSort))
            @test Traversals.dists(d2) == Traversals.dists(b2) && ShortestPaths.paths(d2) == ShortestPaths.paths(b2)
            @test Traversals.dists(b2) == Traversals.dists(q2) && ShortestPaths.paths(b2) == ShortestPaths.paths(q2)
        end

        @test ShortestPaths.shortest_paths(g1, 1) isa ShortestPaths.BFSResult
        @test ShortestPaths.shortest_paths(g2, 1) isa ShortestPaths.BFSResult
        m1 = ShortestPaths.shortest_paths(g1, [1, 2])
        m2 = ShortestPaths.shortest_paths(g2, [1, 2])
        @test m1 isa ShortestPaths.BFSResult
        @test m2 isa ShortestPaths.BFSResult
        @test m1.dists == [0, 0, 1, 2, 1]
        @test m2.dists == [0, 0, 1, 2, 1]

        @testset "maximum distance setting limits ShortestPaths.paths found" begin
            G = cycle_graph(8)
            add_edge!(G, 1, 3)
            
            for g in testgraphs(G)
                b = ShortestPaths.shortest_paths(g, 1, ShortestPaths.BFS(maxdist=2))
                @test b.dists == [0, 1, 1, 2, typemax(eltype(b.dists)), typemax(eltype(b.dists)), 2, 1]
            end
        end
    end
