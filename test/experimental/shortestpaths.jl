using LightGraphs.Experimental, LightGraphs.Experimental.ShortestPaths

spsequal(s1, s2) = (s1.dists == s2.dists && s1.parents == s2.parents)
@testset "Shortest Paths" begin
    smallgs = [smallgraph(x) for x in [:house, :housex, :tutte, :karate, :petersen, :truncatedtetrahedron_dir]]
    wg = path_graph(4); add_edge!(wg, 2, 4)
    w = ones(4,4)
    for i in 1:4
        w[i,i] = 0
    end
    w[2,3] = w[3,2] = 10

    @testset "AStar" begin
        function spsequal_astar(s1, s2, el)
            e = Vector{Edge{el}}()
            for i in 1:length(s1.path) - 1
                push!(e, Edge{el}(s1.path[i], s1.path[i+1]))
            end
            return e == s2
        end

        for sg in smallgs
            for g in testgraphs(sg)
                sp1 = @inferred shortest_paths(g, 1, nv(g), AStar())
                sp2 = a_star(g, 1, nv(g))
                @test spsequal_astar(sp1, sp2, eltype(g))
            end
            sp1 = @inferred shortest_paths(wg, 1, nv(wg), w, AStar())
            sp2 = a_star(wg, 1, nv(wg), w)
            @test spsequal_astar(sp1, sp2, eltype(wg))
        end
    end

    @testset "BellmanFord" begin
        for sg in smallgs
            for g in testgraphs(sg)
                sp1 = @inferred shortest_paths(g, 1, BellmanFord())
                sp2 = bellman_ford_shortest_paths(g, 1)
                @test spsequal(sp1, sp2)
                @test paths(sp1) == enumerate_paths(sp2)
            end
            sp1 = @inferred shortest_paths(wg, 1, w, BellmanFord())
            sp2 = bellman_ford_shortest_paths(wg, 1, w)
            @test spsequal(sp1, sp2)
            @test paths(sp1) == enumerate_paths(sp2)
        end
    end

    @testset "DEsopoPape" begin
        for sg in smallgs
            for g in testgraphs(sg)
                sp1 = @inferred shortest_paths(g, 1, DEsopoPape())
                sp2 = desopo_pape_shortest_paths(g, 1)
                @test spsequal(sp1, sp2)
                @test paths(sp1) == enumerate_paths(sp2)
            end
            sp1 = @inferred shortest_paths(wg, 1, w, DEsopoPape())
            sp2 = desopo_pape_shortest_paths(wg, 1, w)
            @test spsequal(sp1, sp2)
            @test paths(sp1) == enumerate_paths(sp2)
        end
    end

    @testset "Dijkstra" begin
        function spsequal_dijkstra(s1, s2)
            return spsequal(s1, s2) &&
                s1.predecessors == s2.predecessors &&
                s1.pathcounts == s2.pathcounts
        end
        for all_paths in [true, false]
            for track_vertices in [true, false]
                d = Dijkstra(all_paths, track_vertices)
                for sg in smallgs
                    for g in testgraphs(sg)
                        sp1 = @inferred shortest_paths(g, 1, d)
                        sp2 = dijkstra_shortest_paths(g, 1; allpaths=all_paths, trackvertices=track_vertices)
                        @test spsequal_dijkstra(sp1, sp2)
                        @test paths(sp1) == enumerate_paths(sp2)
                    end
                end
            end
        end
        sp1 = @inferred shortest_paths(wg, 1, w, Dijkstra(true, true))
        sp2 = dijkstra_shortest_paths(wg, 1, w, allpaths=true, trackvertices=true)
        @test spsequal_dijkstra(sp1, sp2)
        @test paths(sp1) == enumerate_paths(sp2)
    end

    @testset "FloydWarshall" begin
        for sg in smallgs
            for g in testgraphs(sg)
                sp1 = @inferred shortest_paths(g, FloydWarshall())
                sp2 = floyd_warshall_shortest_paths(g)
                @test spsequal(sp1, sp2)
                @test paths(sp1) == enumerate_paths(sp2)
            end
            sp1 = @inferred shortest_paths(wg, w, FloydWarshall())
            sp2 = floyd_warshall_shortest_paths(wg, w)
            @test spsequal(sp1, sp2)
            @test paths(sp1) == enumerate_paths(sp2)
        end
    end

    @testset "Johnson" begin
        for sg in smallgs
            for g in testgraphs(sg)
                sp1 = @inferred shortest_paths(g, Johnson())
                sp2 = johnson_shortest_paths(g)
                @test spsequal(sp1, sp2)
                @test paths(sp1) == enumerate_paths(sp2)
            end
            sp1 = @inferred shortest_paths(wg, w, Johnson())
            sp2 = johnson_shortest_paths(wg, w)
            @test spsequal(sp1, sp2)
            @test paths(sp1) == enumerate_paths(sp2)
        end
    end
end
