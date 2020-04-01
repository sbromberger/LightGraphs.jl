@testset "LCENT.Betweenness" begin
    # self loops
    s2 = SimpleDiGraph(3)
    add_edge!(s2, 1, 2); add_edge!(s2, 2, 3); add_edge!(s2, 3, 3)
    s1 = SimpleGraph(s2)
    g3 = path_graph(5)

    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-bc.txt"), ','))
    for g in testdigraphs(gint)
        z  = @inferred(LCENT.centrality(g, LCENT.Betweenness()))
        @test map(Float32, z)  == map(Float32, c)

        y  = @inferred(LCENT.centrality(g, LCENT.Betweenness(endpoints=true, normalize=false)))
        @test round.(y[1:3], digits=4) ==
            round.([122.10760591498584, 159.0072453120582, 176.39547945994505], digits=4)

        x  = @inferred(LCENT.centrality(g, LCENT.Betweenness(vs=[3])))
        x2  = @inferred(LCENT.centrality(g, LCENT.Betweenness(vs=1:20)))
        x3 = @inferred(LCENT.centrality(g, LCENT.Betweenness(k=4)))
        @test length(x) == 50
        @test length(x2) == 50
        @test length(x3) == 50
    end

    @test @inferred(LCENT.centrality(s1, LCENT.Betweenness())) == [0, 1, 0]
    @test @inferred(LCENT.centrality(s2, LCENT.Betweenness())) == [0, 0.5, 0]
    
    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    z  = @inferred(LCENT.centrality(g, LCENT.Betweenness(normalize=true)))
    @test z[1] == z[2] == 0.0
    z2  = @inferred(LCENT.centrality(g, LCENT.Betweenness(vs=vertices(g))))
    z3  = @inferred(LCENT.centrality(g, LCENT.Betweenness(vs=[vertices(g);])))
    @test z == z2 == z3


    z  = @inferred(LCENT.centrality(g3, LCENT.Betweenness(normalize=false)))
    @test z[1] == z[5] == 0.0

    # Weighted Graph tests
    g = Graph(6)
    add_edge!(g, 1, 2)
    add_edge!(g, 2, 3)
    add_edge!(g, 3, 4)
    add_edge!(g, 2, 5)
    add_edge!(g, 5, 6)
    add_edge!(g, 5, 4)

    distmx = [ 0.0  2.0  0.0  0.0  0.0  0.0;
               2.0  0.0  4.2  0.0  1.2  0.0;
               0.0  4.2  0.0  5.5  0.0  0.0;
               0.0  0.0  5.5  0.0  0.9  0.0;
               0.0  1.2  0.0  0.9  0.0  0.6;
               0.0  0.0  0.0  0.0  0.6  0.0;]

    @test isapprox(LCENT.centrality(g, distmx, LCENT.Betweenness(vs=vertices(g), normalize=false)), [0.0,6.0,0.0,0.0,6.0,0.0])
    @test isapprox(LCENT.centrality(g, distmx, LCENT.Betweenness(vs=vertices(g), normalize=false, endpoints=true)), [5.0,11.0,5.0,5.0,11.0,5.0])
    @test isapprox(LCENT.centrality(g, distmx, LCENT.Betweenness(vs=vertices(g), normalize=true)), [0.0, 0.6000000000000001, 0.0, 0.0, 0.6000000000000001, 0.0])
    @test isapprox(LCENT.centrality(g, distmx, LCENT.Betweenness(vs=vertices(g), normalize=true, endpoints=true)), [0.5,1.1,0.5,0.5,1.1,0.5])

    adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
    a2 = SimpleDiGraph(adjmx2)
    for g in testdigraphs(a2)
        distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]
        c2 = [0.24390243902439027,0.27027027027027023,0.1724137931034483]
        @test isapprox(LCENT.centrality(g, distmx2, LCENT.Betweenness(vs=vertices(g), normalize=false)), [0.0,1.0,0.0])
        @test isapprox(LCENT.centrality(g, distmx2, LCENT.Betweenness(vs=vertices(g), normalize=false, endpoints=true)), [4.0,5.0,4.0])
        @test isapprox(LCENT.centrality(g, distmx2, LCENT.Betweenness(vs=vertices(g), normalize=true)), [0.0,0.5,0.0])
        @test isapprox(LCENT.centrality(g, distmx2, LCENT.Betweenness(vs=vertices(g), normalize=true, endpoints=true)), [2.0,2.5,2.0])
    end
end
