@testset "DistributedStress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), Int))
    for g in testdigraphs(gint)

        z  = LCENT.centrality(g, LCENT.Stress())
        zd  = LCENT.centrality(g, LCENT.DistributedStress())
        @test z == zd == c

        xd = LCENT.centrality(g, LCENT.DistributedStress(k=3))
        @test length(xd) == 50
        
        xd2 = LCENT.centrality(g, LCENT.DistributedStress(vs=collect(1:20)))
        @test length(xd2) == 50
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)

    for g in testgraphs(g1)
        zd = LCENT.centrality(g, LCENT.DistributedStress())
        @test zd == [4, 2, 4, 10, 0]
    end
end
