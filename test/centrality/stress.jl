@testset "Stress" begin
    gint = loadgraph(joinpath(testdir, "testdata", "graph-50-500.jgz"), "graph-50-500")

    c = vec(readcsv(joinpath(testdir, "testdata", "graph-50-500-sc.txt")))
    for g in testdigraphs(gint)
        z  = @inferred(stress_centrality(g))
        zp = @inferred(parallel_stress_centrality(g))
        @test z == zp == c

        x  = @inferred(stress_centrality(g, 3))
        xp = parallel_stress_centrality(g, 3)

        x2  = @inferred(stress_centrality(g, collect(1:20)))
        xp2 = parallel_stress_centrality(g, collect(1:20))

        @test length(x) == 50
        @test length(xp) == 50
        @test length(x2) == 50
        @test length(xp2) == 50
    end

    g1 = CycleGraph(4)
    add_vertex!(g1)
    add_edge!(g1, 4, 5)
    for g in testgraphs(g1)
        z  = @inferred(stress_centrality(g))
        zp = parallel_stress_centrality(g)
        @test z == zp == [4, 2, 4, 10, 0]
    end
end
