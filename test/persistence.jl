(f,fio) = mktemp()
@test write(p1, f) == 1
@test write(p1, f; compress=false) == 1
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(write, p1)) == 478
@test length(sprint(write, p2)) == 69

rm(f)

#Try reading in a GraphML file from the Rome Graph collection
#http://www.graphdrawing.org/data/
let gs = readgraphml(joinpath(testdir, "testdata/grafo1853.13.graphml"))
    @test length(gs) == 1
    @test haskey(gs, "G") #Name of graph
    g = gs["G"]
    @test nv(g) == 13
    @test ne(g) == 15
end

let gs = readgml(joinpath(testdir,"testdata/twographs-10-28.gml"))
    gml1 = gs["gml1"]
    gml2 = gs["Unnamed DiGraph"]

    @test nv(gml1) == nv(gml2) == 10
    @test ne(gml1) == ne(gml2) == 28
end
