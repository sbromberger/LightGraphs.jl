(f,fio) = mktemp()
@test write(p1, f) == 1
@test write(p1, f; compress=false) == 1
@test write(p2, f; compress=false) == 1
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(write, p1)) == 478
@test length(sprint(write, p2)) == 69

rm(f)

#Try reading in a GraphML file from the Rome Graph collection
#http://www.graphdrawing.org/data/
gs = readgraphml(joinpath(testdir, "testdata/grafo1853.13.graphml"))
@test length(gs) == 1
@test haskey(gs, "G") #Name of graph
g = gs["G"]
@test nv(g) == 13
@test ne(g) == 15

gs = readgraphml(joinpath(testdir, "testdata/twounnamedgraphs.graphml"))
@test gs["Unnamed Graph"] == Graph(gs["Unnamed DiGraph"])

gs = readgml(joinpath(testdir,"testdata/twographs-10-28.gml"))
gml1 = gs["gml1"]
gml2 = gs["Unnamed DiGraph"]

@test nv(gml1) == nv(gml2) == 10
@test ne(gml1) == ne(gml2) == 28


gs = readgraph(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"), "pathdigraph")["pathdigraph"]
@test gs == p2

# test the writes
# redirecting stdout per https://thenewphalls.wordpress.com/2014/03/21/capturing-output-in-julia/
origSTDOUT = STDOUT
(outread, outwrite) = redirect_stdout()
@test write(g3) == 1
@test write(g4) == 1
flush(outread)
flush(outwrite)
close(outread)
close(outwrite)
redirect_stdout(origSTDOUT)
