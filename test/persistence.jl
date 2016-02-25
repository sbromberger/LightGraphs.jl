(f,fio) = mktemp()
# test :lg
@test save(f, p1) == 1
@test save(f, p1; compress=true) == 1
@test save(f, p2; compress=true) == 1
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(save, p1, "p1")) == 398
@test length(sprint(save, p2, "p2")) == 47
gs = load(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "pathdigraph")
@test gs == p2
@test_throws ErrorException load(joinpath(testdir, "testdata", "tutte-pathdigraph.jgz"), "badname")

d = Dict{AbstractString, SimpleGraph}("p1"=>p1, "p2"=>p2)
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
println(keys(gs))
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
gs = load(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), :gml)
gml1 = gs["graph"]
gml2 = gs["digraph"]
@test nv(gml1) == 4
@test ne(gml1) == 6
@test nv(gml2) == 4
@test ne(gml2) == 9
@test_throws ErrorException load(joinpath(testdir, "testdata", "twounnamedgraphs.gml"), "badname", :gml)

# test :dot
gs = load(joinpath(testdir, "testdata", "twographs.dot"), :dot)
@test length(gs) == 2
@test gs["g1"] == CompleteGraph(6)
@test nv(gs["g2"]) == 4 && ne(gs["g2"]) == 6 && is_directed(gs["g2"])
@test_throws ErrorException load(joinpath(testdir, "testdata", "twographs.dot"), "badname", :dot)

# test :gexf
@test save(f, p1, :gexf) == 1
@test_throws ErrorException load(STDIN, :gexf)

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
