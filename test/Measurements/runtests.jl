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
        @testset "eccentricity" begin
            @test z == [6.2, 4.2, 6.2]
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
        @testset "LMS.eccentricity" begin
            @test z == [6.2, 4.2, 6.1]
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
        @test_logs (:warn, "Infinite path length detected: graph may not be connected") match_mode=:any LMS.eccentricity(g1)
        g2 = path_graph(2)
        @test_logs LMS.eccentricity(g2)
    end
end
