@testset "Distance" begin
    g4 = PathDiGraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a1 = Graph(adjmx1)
    a2 = DiGraph(adjmx2)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

    for g in testdigraphs(g4)
        @test_throws ErrorException eccentricity(g)
    end
    for g in testgraphs(a1)
        z = @inferred(eccentricity(g, distmx1))
        @test z == [6.2, 4.2, 6.2]
        @test @inferred(diameter(z)) == diameter(g, distmx1) == 6.2
        @test @inferred(periphery(z)) == periphery(g, distmx1) == [1,3]
        @test @inferred(radius(z)) == radius(g, distmx1) == 4.2
        @test @inferred(center(z)) == center(g, distmx1) == [2]
    end

    for g in testdigraphs(a2)
        z = @inferred(eccentricity(g, distmx2))
        @test z == [6.2, 4.2, 6.1]
        @test @inferred(diameter(z)) == diameter(g, distmx2) == 6.2
        @test @inferred(periphery(z)) == periphery(g, distmx2) == [1]
        @test @inferred(radius(z)) == radius(g, distmx2) == 4.2
        @test @inferred(center(z)) == center(g, distmx2) == [2]
    end
    @test size(LightGraphs.DefaultDistance()) == (typemax(Int), typemax(Int))
    d = @inferred(LightGraphs.DefaultDistance(3))
    @test size(d) == (3, 3)
    @test d[1,1] == getindex(d, 1, 1) == 1
    @test d[1:2, 1:2] == LightGraphs.DefaultDistance(2)
    @test d == transpose(d) == ctranspose(d)
end
