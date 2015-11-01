g =CompleteBipartiteGraph(2,2)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10.
w[Edge(1,4)] = 1.
w[Edge(2,3)] = 2.
w[Edge(2,4)] = 11.
match = maximum_weight_maximal_matching(g,w)
@test match.weight == 21
@test match.inmatch[Edge(1,3)] == true
@test match.inmatch[Edge(1,4)] == false
@test match.inmatch[Edge(2,3)] == false
@test match.inmatch[Edge(2,4)] == true
@test match.π[1] == 3
@test match.π[3] == 1
@test match.π[2] == 4
@test match.π[4] == 2

g =CompleteBipartiteGraph(2,4)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 1
match = maximum_weight_maximal_matching(g,w)
@test match.weight == 11.5
@test match.inmatch[Edge(1,3)] == false
@test match.inmatch[Edge(1,4)] == true
@test match.inmatch[Edge(2,3)] == true
@test match.inmatch[Edge(2,4)] == false
@test match.inmatch[Edge(2,5)] == false
@test match.inmatch[Edge(2,6)] == false
@test match.inmatch[Edge(1,5)] == false
@test match.inmatch[Edge(1,6)] == false
@test match.π[1] == 4
@test match.π[4] == 1
@test match.π[2] == 3
@test match.π[3] == 2

g =CompleteBipartiteGraph(2,4)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 1
w[Edge(2,5)] = -1
w[Edge(2,6)] = -1
match = maximum_weight_maximal_matching(g,w,0)
@test match.weight == 11.5
@test match.inmatch[Edge(1,3)] == false
@test match.inmatch[Edge(1,4)] == true
@test match.inmatch[Edge(2,3)] == true
@test match.inmatch[Edge(2,4)] == false
@test match.inmatch[Edge(2,5)] == false
@test match.inmatch[Edge(2,6)] == false
@test match.inmatch[Edge(1,5)] == false
@test match.inmatch[Edge(1,6)] == false
@test match.π[1] == 4
@test match.π[4] == 1
@test match.π[2] == 3
@test match.π[3] == 2
