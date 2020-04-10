@testset "ThreadedStress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), Int))
    for g in testdigraphs(gint)

        z  = LCENT.centrality(g, LCENT.Stress())
        zt  = LCENT.centrality(g, LCENT.ThreadedStress())
        @test z == zt == c 

        xt = LCENT.centrality(g, LCENT.ThreadedStress(k=3))
        @test length(xt) == 50
        
        xt2 = LCENT.centrality(g, LCENT.ThreadedStress(vs=collect(1:20)))
        @test length(xt2) == 50
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)

    for g in testgraphs(g1)
        zt = LCENT.centrality(g, LCENT.ThreadedStress())
        @test zt == [4, 2, 4, 10, 0]
    end
end
