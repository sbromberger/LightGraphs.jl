@testset "Persistence" begin
    @test_throws ErrorException LightGraphs._NI("Not implemented")
    pdict = loadgraphs(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    p2 = pdict["pathdigraph"]
    g3 = PathGraph(5)

    (f, fio) = mktemp()
    # test :lg
    @test savegraph(f, p1) == 1
    @test savegraph(f, p1; compress=true) == 1
    @test savegraph(f, p1, LGFormat(); compress=true) == 1
    @test savegraph(f, p2; compress=true) == 1
    @test (ne(p2), nv(p2)) == (9, 10)
    
    g2 = loadgraph(f)
    @test (ne(g2), nv(g2)) == (9, 10)
    # test try block (#701)
    @test_throws TypeError savegraph(f, p2; compress=nothing)

    (f, fio) = mktemp()
    @test length(sprint(savegraph, p1, LGFormat())) == 421
    @test length(sprint(savegraph, p2, LGFormat())) == 70
    gs = loadgraph(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "pathdigraph")
    @test gs == p2
    @test_throws ErrorException loadgraph(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "badname")

    d = Dict{String,AbstractGraph}("p1" => p1, "p2" => p2)
    @test savegraph(f, d) == 2
    # test try block (#701)
    @test_throws TypeError savegraph(f, d; compress=nothing)
    
    close(fio)
    rm(f)
end
