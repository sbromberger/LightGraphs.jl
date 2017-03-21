@testset "Persistence" begin
    pdict = load(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    p2 = pdict["pathdigraph"]
    g3 = PathGraph(5)

    function readback_test(format::Symbol, g::Graph, gname="g",
                           remove=true, fnamefio=mktemp())
        fname,fio = fnamefio
        close(fio)
        @test save(fname, g, format) == 1
        @test load(fname, format)[gname] == g
        @test load(fname, gname, format) == g
        if remove
            rm(fname)
        else
            info("persistence/readback_test: Left temporary file at: $fname")
        end
    end

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


    # test :graphml
    @test save(f, p1, :graphml) == 1
    gs = load(joinpath(testdir, "testdata", "grafo1853.13.graphml"), :graphml)
    @test length(gs) == 1
    @test haskey(gs, "G") #Name of graph
    graphml_g = gs["G"]
    @test nv(graphml_g) == 13
    @test ne(graphml_g) == 15
    gs = load(joinpath(testdir, "testdata", "twounnamedgraphs.graphml"), :graphml)
    @test gs["graph"] == Graph(gs["digraph"])
    @test save(f, g3, :graphml) == 1
    @test_throws ErrorException load(joinpath(testdir, "testdata", "twounnamedgraphs.graphml"), "badname", :graphml)
    # test a graphml load that results in a warning
    # redirecting per https://thenewphalls.wordpress.com/2014/03/21/capturing-output-in-julia/
    origSTDERR = STDERR
    (outread, outwrite) = redirect_stderr()
    gs = load(joinpath(testdir,"testdata","warngraph.graphml"), :graphml)
    gsg = load(joinpath(testdir,"testdata","warngraph.graphml"), "G", :graphml)
    @test_throws KeyError badgraph = load(joinpath(testdir, "testdata", "badgraph.graphml"), :graphml)
    flush(outread)
    flush(outwrite)
    close(outread)
    close(outwrite)
    redirect_stderr(origSTDERR)
    @test gs["G"] == graphml_g == gsg



    # test :gml
    gs = load(joinpath(testdir,"testdata", "twographs-10-28.gml"), :gml)
    gml1 = gs["gml1"]
    gml2 = gs["digraph"]
    gml1a = load(joinpath(testdir,"testdata", "twographs-10-28.gml"), "gml1", :gml)
    @test gml1a == gml1
    @test nv(gml1) == nv(gml2) == 10
    @test ne(gml1) == ne(gml2) == 28
    gml1a = load(joinpath(testdir,"testdata", "twographs-10-28.gml"), "gml1", :gml)
    @test gml1a == gml1
    gs = load(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), :gml)
    gml1 = gs["graph"]
    gml2 = gs["digraph"]
    @test nv(gml1) == 4
    @test ne(gml1) == 6
    @test nv(gml2) == 4
    @test ne(gml2) == 9
    @test_throws ErrorException load(joinpath(testdir, "testdata", "twounnamedgraphs.gml"), "badname", :gml)

    @test save(f, gml1, :gml) == 1
    gml1 = load(f, :gml)["graph"]
    @test nv(gml1) == 4
    @test ne(gml1) == 6

    gs = load(joinpath(testdir,"testdata", "twographs-10-28.gml"), :gml)
    @test save(f, gs, :gml) == 2
    gs = load(f, :gml)
    gml1 = gs["gml1"]
    gml2 = gs["digraph"]
    @test nv(gml1) == nv(gml2) == 10
    @test ne(gml1) == ne(gml2) == 28


    # test :dot
    gs = load(joinpath(testdir, "testdata", "twographs.dot"), :dot)
    @test length(gs) == 2
    @test gs["g1"] == CompleteGraph(6)
    @test nv(gs["g2"]) == 4 && ne(gs["g2"]) == 6 && is_directed(gs["g2"])
    @test_throws ErrorException load(joinpath(testdir, "testdata", "twographs.dot"), "badname", :dot)

    # test :gexf
    @test save(f, p1, :gexf) == 1
    @test_throws ErrorException load(STDIN, :gexf)

    #test :graph6
    n1 = (30, UInt8.([93]))
    n2 = (12345, UInt8.([126; 66; 63; 120]))
    n3 = (460175067, UInt8.([126; 126; 63; 90; 90; 90; 90; 90]))
    ns = [n1; n2; n3]
    for n in ns
        @test LightGraphs._g6_N(n[1]) == n[2]
        @test LightGraphs._g6_Np(n[2])[1] == n[1]
    end

    gs = load(joinpath(testdir,"testdata", "twographs.g6"), :graph6)
    @test length(gs) == 2
    @test nv(gs["g1"]) == 6 && ne(gs["g1"]) == 5
    @test nv(gs["g2"]) == 6 && ne(gs["g2"]) == 6


    graphs = [PathGraph(10), CompleteGraph(5), WheelGraph(7)]
    for g in graphs
        readback_test(:graph6, g, "g1")
    end

    (f,fio) = mktemp()
    close(fio)
    d = Dict{String, Graph}("g1"=>CompleteGraph(10), "g2"=>PathGraph(5), "g3" => WheelGraph(7))
    @test save(f,d, :graph6) == 3
    g6graphs = LightGraphs.loadgraph6_mult(fio)
    for (gname, g) in g6graphs
        @test g == d[gnames]
    end
    rm(f)



    #test :net
    g10 = CompleteGraph(10)
    fname,fio = mktemp()
    close(fio)
    @test save(fname, g10, :net) == 1
    @test load(fname,:net)["g"] == g10
    rm(fname)

    g10 = PathDiGraph(10)
    @test save(fname, g10, :net) == 1
    @test load(fname,:net)["g"] == g10
    rm(fname)

    g10 = load(joinpath(testdir, "testdata", "kinship.net"), :net)["g"]
    @test nv(g10) == 6
    @test ne(g10) == 8

    using JLD

    function write_readback(path::String, g)
        jldfile = jldopen(path, "w")
        jldfile["g"] = g
        close(jldfile)

        jldfile = jldopen(path, "r")
        gs = read(jldfile, "g")
        return gs
    end

    function testjldio(path::String, g::Graph)
        gs = write_readback(path, g)
        gloaded = Graph(gs)
        @test gloaded == g
    end

    graphs = [PathGraph(10), CompleteGraph(5), WheelGraph(7)]
    for (i,g) in enumerate(graphs)
        path = joinpath(testdir,"testdata", "test.$i.jld")
        testjldio(path, g)
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end

    for (i,g) in enumerate(graphs)
        eprop = Dict{Edge,Char}([(e, Char(i)) for e in edges(g)])
        net = LightGraphs.Network{Graph, Int, Char}(g, 1:nv(g), eprop)
        path = joinpath(testdir,"testdata", "test.$i.jld")
        nsaved = write_readback(path, net)
        @test LightGraphs.Network(nsaved) == net
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end
end
