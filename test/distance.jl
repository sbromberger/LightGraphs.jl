@testset "Distance" begin
    g4 = path_digraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a1 = SimpleGraph(adjmx1)
    a2 = SimpleDiGraph(adjmx2)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

    @testset "$g" for g in testgraphs(a1)
        z = @inferred(eccentricity(g, distmx1))
        @testset "eccentricity" begin
            @test z == [6.2, 4.2, 6.2]
        end
        @testset "diameter" begin
            @test @inferred(diameter(z)) == diameter(g, distmx1) == 6.2
        end
        @testset "periphery" begin
            @test @inferred(periphery(z)) == periphery(g, distmx1) == [1, 3]
        end
        @testset "radius" begin
            @test @inferred(radius(z)) == radius(g, distmx1) == 4.2
        end
        @testset "center" begin
            @test @inferred(center(z)) == center(g, distmx1) == [2]
        end
    end

    @testset "$g" for g in testgraphs(a2)
        z = @inferred(eccentricity(g, distmx2))
        @testset "eccentricity" begin
            @test z == [6.2, 4.2, 6.1]
        end
        @testset "diameter" begin
            @test @inferred(diameter(z)) == diameter(g, distmx2) == 6.2
        end
        @testset "periphery" begin
            @test @inferred(periphery(z)) == periphery(g, distmx2) == [1]
        end
        @testset "radius" begin
            @test @inferred(radius(z)) == radius(g, distmx2) == 4.2
        end
        @testset "center" begin
            @test @inferred(center(z)) == center(g, distmx2) == [2]
        end
    end
    @testset "DefaultDistance" begin
        @test size(LightGraphs.DefaultDistance()) == (typemax(Int), typemax(Int))
        d = @inferred(LightGraphs.DefaultDistance(3))
        @test size(d) == (3, 3)
        @test d[1, 1] == getindex(d, 1, 1) == 1
        @test d[1:2, 1:2] == LightGraphs.DefaultDistance(2)
        @test d == transpose(d) == adjoint(d)
        @test sprint(show, d) == 
            stringmime("text/plain", d) == 
            "$(d.nv) × $(d.nv) default distance matrix (value = 1)"
    end

    @testset "warnings and errors" begin
    # ensures that eccentricity only throws an error if there is more than one component
        g1 = SimpleGraph(2)
        @test_logs (:warn, "Infinite path length detected for vertex 1") match_mode=:any eccentricity(g1)
        @test_logs (:warn, "Infinite path length detected for vertex 2") match_mode=:any eccentricity(g1)
        g2 = path_graph(2)
        @test_logs eccentricity(g2)
    end
end
