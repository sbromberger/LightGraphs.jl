g =CompleteBipartiteGraph(2,2)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10.
w[Edge(1,4)] = 1.
w[Edge(2,3)] = 2.
w[Edge(2,4)] = 11.
cost, matchmap = maximum_weigth_maximal_matching(g,w,2,2)
@test cost == 21
@test matchmap[Edge(1,3)] == true
@test matchmap[Edge(1,4)] == false
@test matchmap[Edge(2,3)] == false
@test matchmap[Edge(2,4)] == true

g =CompleteBipartiteGraph(2,2)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 1
cost, matchmap = maximum_weigth_maximal_matching(g,w,2,2)
@test cost == 11.5
@test matchmap[Edge(1,3)] == false
@test matchmap[Edge(1,4)] == true
@test matchmap[Edge(2,3)] == true
@test matchmap[Edge(2,4)] == false
