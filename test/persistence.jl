(f,fio) = mktemp()
@test write(p1, f) == 1
@test write(p1, f; compress=false) == 1
@test write(p2, f; compress=false) == 1
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(write, p1)) == 478
@test length(sprint(write, p2)) == 69
@test writegraphml(f, p1) == 1
@test writegexf(f, p1) == 1
rm(f)

#Try reading in a GraphML file from the Rome Graph collection
#http://www.graphdrawing.org/data/
gs = readgraphml(joinpath(testdir, "testdata", "grafo1853.13.graphml"))
@test length(gs) == 1
@test haskey(gs, "G") #Name of graph
graphml_g = gs["G"]
@test nv(graphml_g) == 13
@test ne(graphml_g) == 15

gs = readgraphml(joinpath(testdir, "testdata", "twounnamedgraphs.graphml"))
@test gs["Unnamed Graph"] == Graph(gs["Unnamed DiGraph"])


gs = readgml(joinpath(testdir,"testdata", "twographs-10-28.gml"))
gml1 = gs["gml1"]
gml2 = gs["Unnamed DiGraph"]

@test nv(gml1) == nv(gml2) == 10
@test ne(gml1) == ne(gml2) == 28

gs = readgml(joinpath(testdir,"testdata", "twounnamedgraphs.gml"))
gml1 = gs["Unnamed Graph"]
gml2 = gs["Unnamed DiGraph"]
@test nv(gml1) == 4
@test ne(gml1) == 6
@test nv(gml2) == 4
@test ne(gml2) == 9

@test_throws ErrorException badgraph = readgraphml(joinpath(testdir, "testdata", "badgraph.graphml"))

gs = readgraph(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "pathdigraph")["pathdigraph"]
@test gs == p2

gs = readdot(joinpath(testdir, "testdata", "twographs.dot"))
@test length(gs) == 2
@test gs["g1"] == CompleteGraph(6)
@test nv(gs["g2"]) == 4 && ne(gs["g2"]) == 6 && is_directed(gs["g2"])
@test_throws KeyError readdot(joinpath(testdir, "testdata", "twographs.dot"))["badname"]

# test the writes
# redirecting stdout per https://thenewphalls.wordpress.com/2014/03/21/capturing-output-in-julia/
origSTDOUT = STDOUT
(outread, outwrite) = redirect_stdout()
@test write(g3) == 1
@test write(g4) == 1
@test writegraphml(g3) == 1
@test writegraphml(STDOUT, g3) == 1
@test writegraphml(STDOUT, g4) == 1
@test writegexf(g3) == 1
@test writegexf(g4) == 1
@test writegexf(STDOUT, g3) == 1
@test writegexf(STDOUT, g4) == 1
h5 = CompleteDiGraph(5)
@test writenet(g3) == 1
@test writenet(h5) == 1
path = joinpath(testdir,"testdata","test4.net")
@test writenet(path, g3) == 1
@test writenet(path, h5) == 1
flush(outread)
flush(outwrite)
close(outread)
close(outwrite)
redirect_stdout(origSTDOUT)
# test a graphml load that results in a warning
origSTDERR = STDERR
(outread, outwrite) = redirect_stderr()
gs = readgraphml(joinpath(testdir,"testdata","warngraph.graphml"))
flush(outread)
flush(outwrite)
close(outread)
close(outwrite)
redirect_stderr(origSTDERR)
@test gs["G"] == graphml_g


g10 = readnet(joinpath(testdir,"testdata", "test1.net"))
h10 =DiGraph(3)
add_edge!(h10,1,2)
add_edge!(h10,2,3)
add_edge!(h10,1,3)
add_edge!(h10,3,1)
@test g10 == h10

g10 = readnet(joinpath(testdir,"testdata", "test2.net"))
h10 =DiGraph(3)
add_edge!(h10,1,2)
add_edge!(h10,2,3)
@test g10 == h10

g10 = readnet(joinpath(testdir,"testdata", "test3.net"))
h10 =Graph(3)
add_edge!(h10,1,3)
@test g10 == h10
