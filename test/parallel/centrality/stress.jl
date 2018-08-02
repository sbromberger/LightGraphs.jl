@testset "Parallel.Stress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), ','))
    for g in testdigraphs(gint)
        z  = LightGraphs.stress_centrality(g)
        zp = @inferred(Parallel.stress_centrality(g))
        @test z == zp == c

        xp = Parallel.stress_centrality(g, 3)
        xp2 = Parallel.stress_centrality(g, collect(1:20))
        @test length(xp) == 50
        @test length(xp2) == 50
    end

    g1 = CycleGraph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)

    for g in testgraphs(g1)
        zp = Parallel.stress_centrality(g)
        @test zp == [4, 2, 4, 10, 0]
    end
end


