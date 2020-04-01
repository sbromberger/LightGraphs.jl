@testset "Radiality" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-rc.txt"), ','))
    for g in testdigraphs(gint)
        z  = @inferred(LCENT.centrality(g, LCENT.Radiality()))
        @test z == c
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        z  = @inferred(LCENT.centrality(g, LCENT.Radiality()))
        @test z ≈ [5 // 6, 3 // 4, 5 // 6, 11 // 12, 2 // 3]
    end
end
