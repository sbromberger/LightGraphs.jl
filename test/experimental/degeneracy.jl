using LightGraphs.Experimental

@testset "Threaded Core Number" begin
    d = loadgraph(joinpath(testdir, "testdata", "graph-decomposition.jgz"))
    for g in testgraphs(d)
        @test threaded_core_number(g) == [3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]
        @test threaded_core_number(g, 0.5) == [3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 0]
        add_edge!(g, 1, 1)
        @test_throws ArgumentError threaded_core_number(g) 
    end
end
