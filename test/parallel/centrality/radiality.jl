@testset "Parallel.Radiality" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-rc.txt"), ','))
    for g in testdigraphs(gint)
        zd = @inferred(Parallel.radiality_centrality(g; parallel=:distributed))
        @test zd == c
        zt = @inferred(Parallel.radiality_centrality(g; parallel=:threads))
        @test zt == c
    end

    g1 = CycleGraph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        zd = @inferred(Parallel.radiality_centrality(g; parallel=:distributed))
        @test zd ≈ [5 // 6, 3 // 4, 5 // 6, 11 // 12, 2 // 3]
        zt = @inferred(Parallel.radiality_centrality(g; parallel=:threads))
        @test zt ≈ [5 // 6, 3 // 4, 5 // 6, 11 // 12, 2 // 3]
    end
end
