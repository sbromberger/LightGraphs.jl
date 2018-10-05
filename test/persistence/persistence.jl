@testset "Persistence" begin
    @test_throws ErrorException LightGraphs._NI("Not implemented")
    pdict = loadgraphs(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    p2 = pdict["pathdigraph"]
    g3 = PathGraph(5)

    (f, fio) = mktemp()
    # test :lg
    @test savegraph(f, p1) == 1
    @test_deprecated r"Saving compressed graphs is no longer supported" savegraph(f, p1; compress=true)
    @test savegraph(f, p1) == 1
    @test_deprecated r"Saving compressed graphs is no longer supported" savegraph(f, p1, LGFormat(); compress=true)
    @test_logs (:info,r"Note: the `compress` keyword is no longer supported in LightGraphs") savegraph(f, p1; compress=false)
    @test savegraph(f, p1, LGFormat()) == 1
    @test savegraph(f, p2) == 1
    @test (ne(p2), nv(p2)) == (9, 10)
    
    g2 = loadgraph(f)
    h2 = loadgraph(f, LGFormat())
    j2 = loadgraph(f, "graph")
    @test g2 == h2 == j2
    @test (ne(g2), nv(g2)) == (9, 10)

    (f, fio) = mktemp()
    @test length(sprint(savegraph, p1, LGFormat())) == 421
    @test length(sprint(savegraph, p2, LGFormat())) == 70
    gs = loadgraph(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "pathdigraph")
    @test gs == p2
    @test_throws ArgumentError loadgraph(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "badname")

    d = Dict{String,AbstractGraph}("p1" => p1, "p2" => p2)
    @test savegraph(f, d) == 2
    
    close(fio)
    rm(f)
end
