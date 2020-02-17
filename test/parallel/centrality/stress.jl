@testset "Parallel.Stress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")
    c = vec(readdlm(joinpath(testdir, "testdata", "graph-50-500-sc.txt"), ','))
    for g in testdigraphs(gint)

        z  = LightGraphs.stress_centrality(g)
        zd = @inferred(Parallel.stress_centrality(g; parallel=:distributed))
        @test z == zd == c
        zt = @inferred(Parallel.stress_centrality(g; parallel=:threads))
        @test z == zt == c 

        xd = Parallel.stress_centrality(g, 3; parallel=:distributed)
        @test length(xd) == 50
        xt = Parallel.stress_centrality(g, 3; parallel=:threasd)
        @test length(xt) == 50
        
        xd2 = Parallel.stress_centrality(g, collect(1:20); parallel=:distributed)
        @test length(xd2) == 50
        xt2 = Parallel.stress_centrality(g, collect(1:20); parallel=:threads)
        @test length(xt2) == 50
    end

    g1 = cycle_graph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)

    for g in testgraphs(g1)
        zd = Parallel.stress_centrality(g; parallel=:distributed)
        @test zd == [4, 2, 4, 10, 0]
        zt = Parallel.stress_centrality(g; parallel=:threads)
        @test zt == [4, 2, 4, 10, 0]
    end
end
