@testset "DistributedBetweenness" begin

    s2 = SimpleDiGraph(3)
    add_edge!(s2, 1, 2); add_edge!(s2, 2, 3); add_edge!(s2, 3, 3)
    s1 = SimpleGraph(s2)
    g3 = path_graph(5)
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    for g in testdigraphs(gint)
        z  = @inferred(LCENT.centrality(g, LCENT.Betweenness()))
        zd = @inferred(LCENT.centrality(g, LCENT.DistributedBetweenness()))
        @test all(isapprox.(z, zd))

        y  = LCENT.centrality(g, LCENT.Betweenness(endpoints=true, normalize=false))
        yd = LCENT.centrality(g, LCENT.DistributedBetweenness(endpoints=true, normalize=false))
        @test all(isapprox(y, yd))

        xd = @inferred(LCENT.centrality(g, LCENT.DistributedBetweenness(k=3)))
        @test length(xd) == 50

        xd2 = @inferred(LCENT.centrality(g, LCENT.DistributedBetweenness(vs=collect(1:20))))
        @test length(xd2) == 50
    end
    @test @inferred(LCENT.centrality(s1, LCENT.DistributedBetweenness())) == [0, 1, 0]

    @test @inferred(LCENT.centrality(s2, LCENT.DistributedBetweenness())) == [0, 0.5, 0]

    g = SimpleGraph(2)
    add_edge!(g, 1, 2)
    z = LCENT.centrality(g, LCENT.Betweenness(normalize=true))
    @test z[1] == z[2] == 0.0
    zd = LCENT.centrality(g, LCENT.DistributedBetweenness(normalize=true))
    @test all(isapprox(z, zd))

    z2  = LCENT.centrality(g, LCENT.Betweenness(vs=vertices(g)))
    zd2 = LCENT.centrality(g, LCENT.DistributedBetweenness(vs=vertices(g)))
    @test all(isapprox(z2, zd2))

    z3  = LCENT.centrality(g, LCENT.Betweenness(vs=collect(vertices(g))))
    zd3 = LCENT.centrality(g, LCENT.DistributedBetweenness(vs=collect(vertices(g))))
    @test all(isapprox(z3, zd3))

    @test z == z2 == z3

    z  = LCENT.centrality(g3, LCENT.Betweenness(normalize=false))
    zd = LCENT.centrality(g3, LCENT.DistributedBetweenness(normalize=false))
    @test all(isapprox(z, zd))
    @test z[1] == z[5] == 0.0
end
