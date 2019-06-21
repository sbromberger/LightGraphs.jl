@testset "Parallel.Betweenness" begin

    s2 = SimpleDiGraph(3)
    add_edge!(s2, 1, 2); add_edge!(s2, 2, 3); add_edge!(s2, 3, 3)
    s1 = SimpleGraph(s2)
    g3 = path_graph(5)
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    for g in testdigraphs(gint)
        z  = @inferred(LightGraphs.betweenness_centrality(g))
        zt = @inferred(Parallel.betweenness_centrality(g; parallel=:threads))
        @test all(isapprox.(z, zt))
        zd = @inferred(Parallel.betweenness_centrality(g; parallel=:distributed))
        @test all(isapprox.(z, zd))

        y  = LightGraphs.betweenness_centrality(g, endpoints=true, normalize=false)
        yt = Parallel.betweenness_centrality(g, endpoints=true, normalize=false, parallel=:threads)
        @test all(isapprox(y, yt))
        yd = Parallel.betweenness_centrality(g, endpoints=true, normalize=false, parallel=:distributed)
        @test all(isapprox(y, yd))


        xt = @inferred(Parallel.betweenness_centrality(g, 3; parallel=:threads))
        @test length(xt) == 50
        xd = @inferred(Parallel.betweenness_centrality(g, 3; parallel=:distributed))
        @test length(xd) == 50

        xt2 = @inferred(Parallel.betweenness_centrality(g, collect(1:20); parallel=:threads))
        @test length(xt2) == 50
        xd2 = @inferred(Parallel.betweenness_centrality(g, collect(1:20); parallel=:distributed))
        @test length(xd2) == 50
    end
    @test @inferred(Parallel.betweenness_centrality(s1; parallel=:threads)) == [0, 1, 0]
    @test @inferred(Parallel.betweenness_centrality(s1; parallel=:distributed)) == [0, 1, 0]

    @test @inferred(Parallel.betweenness_centrality(s2; parallel=:threads)) == [0, 0.5, 0]
    @test @inferred(Parallel.betweenness_centrality(s2; parallel=:distributed)) == [0, 0.5, 0]

    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    z  = LightGraphs.betweenness_centrality(g; normalize=true)
    @test z[1] == z[2] == 0.0
    zt = Parallel.betweenness_centrality(g; normalize=true, parallel=:threads)
    @test all(isapprox(z, zt))
    zd = Parallel.betweenness_centrality(g; normalize=true, parallel=:distributed)
    @test all(isapprox(z, zd))

    z2  = LightGraphs.betweenness_centrality(g, vertices(g))
    zt2 = Parallel.betweenness_centrality(g, vertices(g); parallel=:threads)
    @test all(isapprox(z2, zt2))
    zd2 = Parallel.betweenness_centrality(g, vertices(g); parallel=:distributed)
    @test all(isapprox(z2, zd2))

    z3  = LightGraphs.betweenness_centrality(g, [vertices(g);])
    zt3 = Parallel.betweenness_centrality(g, [vertices(g);]; parallel=:threads)
    @test all(isapprox(z3, zt3))
    zd3 = Parallel.betweenness_centrality(g, [vertices(g);]; parallel=:distributed)
    @test all(isapprox(z3, zd3))

    @test z == z2 == z3

    z  = LightGraphs.betweenness_centrality(g3; normalize=false)
    zt = Parallel.betweenness_centrality(g3; normalize=false, parallel=:threads)
    @test all(isapprox(z, zt))
    zd = Parallel.betweenness_centrality(g3; normalize=false, parallel=:distributed)
    @test all(isapprox(z, zd))
    @test z[1] == z[5] == 0.0
end
