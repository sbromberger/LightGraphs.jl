@testset "Parallel.Distance" begin
    g4 = path_digraph(5)
    adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a1 = SimpleGraph(adjmx1)
    a2 = SimpleDiGraph(adjmx2)
    distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
    distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

    for g in testgraphs(a1)
        z = @inferred(LightGraphs.eccentricity(g, distmx1))
        y = @inferred(Parallel.eccentricity(g, distmx1))
        @test isapprox(y, z)
        @test @inferred(LightGraphs.diameter(y)) == @inferred(Parallel.diameter(g, distmx1)) == 6.2
        @test @inferred(LightGraphs.periphery(y)) == @inferred(Parallel.periphery(g, distmx1)) == [1, 3]
        @test @inferred(LightGraphs.radius(y)) == @inferred(Parallel.radius(g, distmx1)) == 4.2
        @test @inferred(LightGraphs.center(y)) == @inferred(Parallel.center(g, distmx1)) == [2]
    end

    for g in testdigraphs(a2)
        z = @inferred(LightGraphs.eccentricity(g, distmx2))
        y = @inferred(Parallel.eccentricity(g, distmx2))
        @test isapprox(y, z)
        @test @inferred(LightGraphs.diameter(y)) == @inferred(Parallel.diameter(g, distmx2)) == 6.2
        @test @inferred(LightGraphs.periphery(y)) == @inferred(Parallel.periphery(g, distmx2)) == [1]
        @test @inferred(LightGraphs.radius(y)) == @inferred(Parallel.radius(g, distmx2)) == 4.2
        @test @inferred(LightGraphs.center(y)) == @inferred(Parallel.center(g, distmx2)) == [2]
    end    
end
