@testset "Parallel.Betweenness" begin

    print("in parallel betweenness tests")
    s2 = SimpleDiGraph(3)
    add_edge!(s2, 1, 2); add_edge!(s2, 2, 3); add_edge!(s2, 3, 3)
    s1 = SimpleGraph(s2)
    g3 = PathGraph(5)
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    for g in testdigraphs(gint)
        z  = @inferred(LightGraphs.betweenness_centrality(g))
        zp = @inferred(Parallel.betweenness_centrality(g))
        @test all(isapprox.(z, zp))

        y  = LightGraphs.betweenness_centrality(g, endpoints=true, normalize=false)
        yp = Parallel.betweenness_centrality(g, endpoints=true, normalize=false)
        @test all(isapprox(y, yp))

        xp = Parallel.betweenness_centrality(g, 3)
        xp2 = Parallel.betweenness_centrality(g, collect(1:20))

        @test length(xp) == 50
        @test length(xp2) == 50
    end
    @test @inferred(Parallel.betweenness_centrality(s1)) == [0, 1, 0]
    @test Parallel.betweenness_centrality(s2)   == [0, 0.5, 0]

    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    z  = LightGraphs.betweenness_centrality(g; normalize=true)
    zp = Parallel.betweenness_centrality(g; normalize=true)
    @test all(isapprox(z, zp))
    @test z[1] == z[2] == 0.0
    z2  = LightGraphs.betweenness_centrality(g, vertices(g))
    zp2 = Parallel.betweenness_centrality(g, vertices(g))
    @test all(isapprox(z2, zp2))
    z3  = LightGraphs.betweenness_centrality(g, [vertices(g);])
    zp3 = Parallel.betweenness_centrality(g, [vertices(g);])
    @test all(isapprox(z3, zp3))

    @test z == z2 == z3

    z  = LightGraphs.betweenness_centrality(g3; normalize=false)
    zp = Parallel.betweenness_centrality(g3; normalize=false)
    @test all(isapprox(z, zp))
    @test z[1] == z[5] == 0.0


end