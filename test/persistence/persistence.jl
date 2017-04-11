@testset "Persistence" begin
    @test_throws ErrorException LightGraphs._NI("Not implemented")
    pdict = load(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    p2 = pdict["pathdigraph"]
    g3 = PathGraph(5)

    (f,fio) = mktemp()
    # test :lg
    @test save(f, p1) == 1
    @test save(f, p1; compress=true) == 1
    @test save(f, p2; compress=true) == 1
    @test (ne(p2), nv(p2)) == (9, 10)

    @test savegraph(f, p1) == 1
    @test savegraph(f, p1; compress=true) == 1
    @test savegraph(f, p2; compress=true) == 1
    dg2 = load(f)
    g2 = loadgraph(f)
    @test (ne(g2), nv(g2)) == (9, 10)


    @test length(sprint(save, p1, "p1")) == 398
    @test length(sprint(save, p2, "p2")) == 47
    gs = load(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "pathdigraph")
    @test gs == p2
    @test_throws ErrorException load(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "badname")

    d = Dict{String, AbstractGraph}("p1"=>p1, "p2"=>p2)
    @test save(f,d) == 2


end
