@testset "Stress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), ','))
    for g in testdigraphs(gint)
        z  = @inferred(LCENT.centrality(g, LCENT.Stress()))
        @test z == c

        x  = @inferred(LCENT.centrality(g, LCENT.Stress(vs=[3])))
        x2  = @inferred(LCENT.centrality(g, LCENT.Stress(vs=1:20)))
        @test length(x) == 50
        @test length(x2) == 50
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        z  = @inferred(LCENT.centrality(g, LCENT.Stress()))
        @test z == [4, 2, 4, 10, 0]
    end
end
