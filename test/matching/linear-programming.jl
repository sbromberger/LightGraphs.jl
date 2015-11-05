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
@test match.m[1] == 3
@test match.m[3] == 1
@test match.m[2] == 4
@test match.m[4] == 2

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
@test match.m[1] == 4
@test match.m[4] == 1
@test match.m[2] == 3
@test match.m[3] == 2

g =CompleteBipartiteGraph(2,6)
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
@test match.m[1] == 4
@test match.m[4] == 1
@test match.m[2] == 3
@test match.m[3] == 2

g =CompleteBipartiteGraph(4,2)
w =Dict{Edge,Float64}()
w[Edge(3,5)] = 10
w[Edge(3,6)] = 0.5
w[Edge(2,5)] = 11
w[Edge(1,6)] = 1
w[Edge(1,5)] = -1

match = maximum_weight_maximal_matching(g,w,0)
@test match.weight == 12
@test match.inmatch[Edge(3,5)] == false
@test match.inmatch[Edge(3,6)] == false
@test match.inmatch[Edge(2,5)] == true
@test match.inmatch[Edge(1,5)] == false
@test match.inmatch[Edge(4,5)] == false
@test match.inmatch[Edge(4,6)] == false
@test match.inmatch[Edge(1,6)] == true
@test match.m[1] == 6
@test match.m[2] == 5
@test match.m[3] == -1
@test match.m[4] == -1
@test match.m[5] == 2
@test match.m[6] == 1
