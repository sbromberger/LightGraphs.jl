using LightGraphs.ShortestPaths

const LMS = LightGraphs.Measurements
@testset "Measurements" begin
    g4 = path_digraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a1 = SimpleGraph(adjmx1)
    a2 = SimpleDiGraph(adjmx2)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

    @testset "$g" for g in testgraphs(a1)
        z = @inferred(LMS.eccentricity(g, distmx1))
        z2 = @inferred(LMS.eccentricity(g))

        @testset "eccentricity" begin
            y = @inferred(LMS.eccentricity(g, vertices(g), distmx1))
            x = @inferred(LMS.eccentricity(g, 1, distmx1))
            tz = @inferred(LMS.eccentricity(g, distmx1, LMS.Threaded()))
            ty = @inferred(LMS.eccentricity(g, vertices(g), distmx1, LMS.Threaded()))
            @test z == y == tz == ty == [6.2, 4.2, 6.2]
            @test y[1] == x
            y2 = @inferred(LMS.eccentricity(g, vertices(g)))
            x2 = @inferred(LMS.eccentricity(g, 1))
            @test z2 == y2 == [2, 1, 2]
            @test y2[1] == x2


        end
        @testset "LMS.diameter" begin
            @test @inferred(LMS.diameter(z)) == LMS.diameter(g, distmx1) == 6.2
        end
        @testset "LMS.periphery" begin
            @test @inferred(LMS.periphery(z)) == LMS.periphery(g, distmx1) == [1, 3]
        end
        @testset "LMS.radius" begin
            @test @inferred(LMS.radius(z)) == LMS.radius(g, distmx1) == 4.2
        end
        @testset "LMS.center" begin
            @test @inferred(LMS.center(z)) == LMS.center(g, distmx1) == [2]
        end
    end

    @testset "$g" for g in testgraphs(a2)
        z = @inferred(LMS.eccentricity(g, distmx2))
        z2 = @inferred(LMS.eccentricity(g))

        @testset "LMS.eccentricity" begin
            y = @inferred(LMS.eccentricity(g, vertices(g), distmx2))
            x = @inferred(LMS.eccentricity(g, 1, distmx2))
            w = @inferred(LMS.eccentricity(g, vertices(g), distmx2, ShortestPaths.Dijkstra()))
            v = @inferred(LMS.eccentricity(g, distmx2, ShortestPaths.Dijkstra()))
            u = @inferred(LMS.eccentricity(g, 1, distmx2, ShortestPaths.Dijkstra()))
            tz = @inferred(LMS.eccentricity(g, distmx2, LMS.Threaded()))
            ty = @inferred(LMS.eccentricity(g, vertices(g), distmx2, LMS.Threaded()))
            tw = @inferred(LMS.eccentricity(g, vertices(g), distmx2, ShortestPaths.Dijkstra(), LMS.Threaded()))
            tv = @inferred(LMS.eccentricity(g, distmx2, ShortestPaths.Dijkstra(), LMS.Threaded()))
            @test z == y == w == v == tz == ty == tw == tv == [6.2, 4.2, 6.1]
            @test y[1] == x == u
            y2 = @inferred(LMS.eccentricity(g, vertices(g)))
            x2 = @inferred(LMS.eccentricity(g, 1))
            w2 = @inferred(LMS.eccentricity(g, ShortestPaths.BFS()))
            v2 = @inferred(LMS.eccentricity(g, vertices(g), ShortestPaths.BFS()))
            u2 = @inferred(LMS.eccentricity(g, 1, ShortestPaths.BFS()))

            ty2 = @inferred(LMS.eccentricity(g, vertices(g), LMS.Threaded()))
            tw2 = @inferred(LMS.eccentricity(g, ShortestPaths.BFS(), LMS.Threaded()))
            tv2 = @inferred(LMS.eccentricity(g, vertices(g), ShortestPaths.BFS(), LMS.Threaded()))
            @test z2 == y2 == w2 == v2 == ty2 == tw2 == tv2 == [2, 1, 1]
            @test y2[1] == x2 == u2
        end
        @testset "diameter" begin
            @test @inferred(LMS.diameter(z)) == LMS.diameter(g, distmx2) == 6.2
        end
        @testset "periphery" begin
            @test @inferred(LMS.periphery(z)) == LMS.periphery(g, distmx2) == [1]
        end
        @testset "radius" begin
            @test @inferred(LMS.radius(z)) == LMS.radius(g, distmx2) == 4.2
        end
        @testset "center" begin
            @test @inferred(LMS.center(z)) == LMS.center(g, distmx2) == [2]
        end
    end

    @testset "warnings and errors" begin
    # ensures that LMS.eccentricity only throws an error if there is more than one component
        g1 = SimpleGraph(2)
        @test_logs (:warn, "Infinite path length detected for vertex 1: graph may not be connected") match_mode=:any LMS.eccentricity(g1)
        @test_logs (:warn, "Infinite path length detected for vertex 2: graph may not be connected") match_mode=:any LMS.eccentricity(g1)
        @test_logs (:warn, "Infinite path length detected for vertex 1: graph may not be connected") match_mode=:any LMS.eccentricity(g1, LMS.Threaded())
        @test_logs (:warn, "Infinite path length detected for vertex 2: graph may not be connected") match_mode=:any LMS.eccentricity(g1, LMS.Threaded())
        g2 = path_graph(2)
        @test_logs LMS.eccentricity(g2)
        @test_logs LMS.eccentricity(g2, LMS.Threaded())
    end
end
