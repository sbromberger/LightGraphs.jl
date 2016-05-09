println("*** Running MatrixDepot tests")
randstr = "LightGraphs/$(rand(1:10000))"
g = MDGraph("hilb", 4)
@test nv(g) == 4 && ne(g) == 10

g = MDDiGraph("baart", 4)
@test nv(g) == 4 && ne(g) == 16

@test_throws ErrorException MDGraph("baart", 4)
println("*** Finished MatrixDepot tests")
