@testset "ThreadedBetweenness" begin

    s2 = SimpleDiGraph(3)
    add_edge!(s2, 1, 2); add_edge!(s2, 2, 3); add_edge!(s2, 3, 3)
    s1 = SimpleGraph(s2)
    g3 = path_graph(5)
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    for g in testdigraphs(gint)
        z  = @inferred(LCENT.centrality(g, LCENT.Betweenness()))
        zt = @inferred(LCENT.centrality(g, LCENT.ThreadedBetweenness()))
        @test all(isapprox.(z, zt))

        y  = LCENT.centrality(g, LCENT.Betweenness(endpoints=true, normalize=false))
        yt = LCENT.centrality(g, LCENT.ThreadedBetweenness(endpoints=true, normalize=false))
        @test all(isapprox(y, yt))

        xt = @inferred(LCENT.centrality(g, LCENT.ThreadedBetweenness(k=3)))
        @test length(xt) == 50

        xt2 = @inferred(LCENT.centrality(g, LCENT.ThreadedBetweenness(vs=collect(1:20))))
        @test length(xt2) == 50
    end
    @test @inferred(LCENT.centrality(s1, LCENT.ThreadedBetweenness())) == [0, 1, 0]

    @test @inferred(LCENT.centrality(s2, LCENT.ThreadedBetweenness())) == [0, 0.5, 0]

    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    z  = LCENT.centrality(g, LCENT.Betweenness(normalize=true))
    @test z[1] == z[2] == 0.0
    zt = LCENT.centrality(g, LCENT.ThreadedBetweenness(normalize=true))
    @test all(isapprox(z, zt))

    z2  = LCENT.centrality(g, LCENT.Betweenness(vs=vertices(g)))
    zt2 = LCENT.centrality(g, LCENT.ThreadedBetweenness(vs=vertices(g)))
    @test all(isapprox(z2, zt2))

    z3  = LCENT.centrality(g, LCENT.Betweenness(vs=collect(vertices(g))))
    zt3  = LCENT.centrality(g, LCENT.ThreadedBetweenness(vs=collect(vertices(g))))
    @test all(isapprox(z3, zt3))

    @test z == z2 == z3

    z  = LCENT.centrality(g3, LCENT.Betweenness(normalize=false))
    zt= LCENT.centrality(g3, LCENT.ThreadedBetweenness(normalize=false))
    @test all(isapprox(z, zt))
    @test z[1] == z[5] == 0.0
end
